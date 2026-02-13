# hypr-workflow

Hyprland workflow tools: group overlay + per-workspace network namespaces.

## What it does

**devns** gives each Hyprland workspace its own network namespace. Programs launched in workspace 2 can't see `localhost` from workspace 3. This means you can run separate dev servers on different workspaces without port conflicts, and Docker containers are reachable from the workspace they were started on.

**group-overlay** shows a visual overlay for Hyprland tab groups.

## Caveats

- IPv4 only — `localhost` is forced to `127.0.0.1` inside namespaces. Apps that rely on `::1` won't work.
- HTTPS localhost bypasses the proxy and extension entirely, so cookies are not workspace-isolated. Use HTTP for local dev.
- The Docker runtime (`hypr-devns-runc`) is registered as the **default OCI runtime**, so all containers are affected. Revert with `hypr-workflow-uninstall`.
- Port publishing is stripped from `docker compose up`/`create`/`run` since it's redundant inside namespaces and would conflict globally. If you need host-published ports (e.g. for access from another machine), run `docker run -p` directly on the host outside a namespace.
- See [Docker limitations](#docker-limitations) for additional edge cases.

## Dependencies

- Hyprland
- jq, socat, iproute2, iptables
- Python 3 with PyGObject + gtk4-layer-shell (for group-overlay)

## Install

Arch Linux (AUR-style local package):

```bash
makepkg -si
```

This installs all scripts to `/usr/bin/` and config to `/etc/`.

## Setup

After installing, run the interactive installer to integrate with your desktop:

```bash
hypr-workflow-install
```

This configures:

- Hyprland autostart (adds `hypr-devns-daemon`)
- Terminal binding (wraps `$terminal` with `hypr-devns-exec`)
- Walker app launcher prefix
- Ghostty single-instance override
- Browser extensions (Chromium, Helium, Zen)
- Docker runtime (registers `hypr-devns-runc` as default OCI runtime)

Reboot after setup, or restart Hyprland, Docker, and your browsers individually.

To undo everything: `hypr-workflow-uninstall`

## Configuration

The package installs defaults at `/etc/hypr-devns.conf`. Override per-user at `~/.config/hypr-devns.conf`:

```bash
# Which workspaces get namespaces: "all" or comma-separated IDs
DEVNS_WORKSPACES=all

# DNS servers inside namespaces
DEVNS_DNS="9.9.9.9 1.1.1.1"

# WAN interface for NAT (auto-detected from default route if empty)
DEVNS_WAN_IFACE=""

# Enable group tab overlay (true/false)
GROUP_OVERLAY=true
```

If WAN auto-detection fails (e.g. multiple default routes, VPN), set `DEVNS_WAN_IFACE` explicitly. Check your current default route with `ip route show default`.

## How it works

Linux lets you create isolated "copies" of the network stack. A process inside a namespace has its own `localhost`, its own ports, its own routing table — completely separate from the host. Two processes in different namespaces can both bind to port 3000 without conflict because they're on different localhosts.

The daemon (`hypr-devns-daemon`) listens to Hyprland IPC and lazily creates one namespace per workspace as you switch between them. Each namespace (`hyprns_1`, `hyprns_2`, ...) gets its own veth pair, NAT, and DNS config.

`hypr-devns-exec` runs a command inside the current workspace's namespace. Every app launched from either the terminal or Walker (via `launch_prefix`) enters the namespace automatically, so most things just work.

Two categories of apps need special handling:

1. **Single-instance apps** that share state across workspaces — opening a "new window" actually reuses the original process and its namespace. This includes all web browsers and some apps like Ghostty (which hardcodes `--gtk-single-instance=true` in its desktop file).
2. **Daemon-managed apps** that start before any workspace context exists, like Docker containers.

Ghostty is the simplest case — the setup script installs a desktop file override that disables single-instance mode, so each window spawns a fresh process that inherits the correct namespace.

### Browser integration

A browser extension + local proxy (`hypr-devns-proxy`) redirects `localhost` requests to the correct namespace IP (`10.200.<ws>.2`) based on which workspace the tab was opened on. A DNAT rule inside each namespace redirects traffic arriving on the veth IP to loopback, and a custom `/etc/hosts` forces `localhost` to resolve to IPv4, so dev servers work transparently without needing to bind to `0.0.0.0`. This sidesteps the single-instance problem at the application layer.

#### Cookie isolation

Since all workspaces share one browser, cookies on `localhost` would collide across workspaces. The proxy and extension transparently namespace cookie names with a `_ws{id}_` prefix (e.g., `_ws3_session`). Two layers make this invisible to app code:

- The proxy rewrites HTTP `Cookie`/`Set-Cookie` headers — stripping the prefix on requests and adding it on responses — so servers never see prefixed names.
- The extension overrides the native `document.cookie` getter/setter, so client JS reading or writing cookies also sees unprefixed names.

The browser stores cookies with prefixed names, but neither server code nor client code ever sees the prefix.

### Docker integration

`hypr-devns-runc` is an OCI runtime wrapper that patches container configs to join the active workspace's network namespace. Docker's bridge networking follows the container, so `localhost` inside the container maps to the workspace's loopback. Containers remember which workspace they were started on across restarts (cached in `/run/`, lost on reboot — recreate containers after reboot).

An alternative approach would be running separate Docker daemons per workspace with a shared image store. This was rejected because each daemon maintains its own build cache, layer deduplication, and container metadata — multiplying memory and disk I/O overhead. The current approach reuses the single daemon and achieves isolation at the OCI runtime and compose layers instead.

Containers created before installation won't be in a workspace namespace — recreate them after setup.

Namespace isolation applies to localhost only — containers can still reach each other via the Docker bridge network or host IP if needed.

#### Compose isolation

A docker wrapper script (injected via `PATH`) handles two things:

1. Sets `COMPOSE_PROJECT_NAME` to `<directory>-ws<id>`, so running the same project in workspaces 2 and 3 creates independent container sets. `docker compose up` / `down` / `ps` only affect the current workspace's containers. Override with `-p <name>` or by setting `COMPOSE_PROJECT_NAME` yourself.

2. Strips port publishing (`ports:` directives) for `up`/`create`/`run` commands. Ports are redundant inside namespaces — containers are reachable via the namespace's localhost directly — and would conflict since Docker's port allocator is global across the single daemon.

#### Docker limitations

1. `docker stats` shows zero network counters for all but the most recently started container per workspace.
2. `docker network disconnect` / `docker network connect` on a running container may fail.
3. If multiple containers in the same workspace are on separate Docker networks, DNS resolution for cross-network service names may not work (same-network is fine).
4. Containers using `--network=none` add a ~5 second delay to the next container start in that workspace.
5. Each container start is serialized per workspace (~200-500ms overhead each) to prevent internal naming conflicts.
