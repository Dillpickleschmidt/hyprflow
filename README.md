<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/banner-dark.svg" />
    <source media="(prefers-color-scheme: light)" srcset="assets/banner-light.svg" />
    <img alt="hyprflow" src="assets/banner-dark.svg" width="500" />
  </picture>
  <br />
  <strong>A better Hyprland workflow for developers</strong>
  <br /><br />
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-Apache%202.0-blue" /></a>
  <img alt="Platform" src="https://img.shields.io/badge/platform-Arch%20Linux-1793d1?logo=archlinux&logoColor=white" />
  <img alt="Hyprland" src="https://img.shields.io/badge/Hyprland-00bcd4?logo=data:image/svg+xml;base64,&logoColor=white" />
  <img alt="Version" src="https://img.shields.io/badge/version-0.3.0-brightgreen" />
  <br /><br />
  Per-group network isolation &bull; Browser &amp; Docker integration &bull; Workspace group overlay
</p>

---

> _"My dream would be a very simple set of desktops that have their own logical consistent behaviors such that I could easily go between the three and have them set up perfectly. In my dream world, each of these would be a different remote computer that I'm controlling from here."_ &mdash; Theo, Feb 2026

Okay, DONE!

Built in response to Theo's [_Agentic Coding Has A HUGE Problem_](https://www.youtube.com/watch?v=YVq28OTPCKw), Hyprflow introduces workspace groups for Hyprland &mdash; each group gets its own network namespace with its own `localhost`. No more port collisions, cookie conflicts, or terminal tab chaos.

[Read the full write-up &rarr;](https://example.com/TODO)

---

<p align="center">
  <a href="https://youtu.be/-yLSomG0_vU">
    <img src="assets/demo-thumb.jpg" alt="Hyprflow Demo" width="720" />
  </a>
</p>

---

## What it does

Hyprflow organizes Hyprland workspaces into **workspace groups** &mdash; sets of 10 workspaces (1-10, 11-20, 21-30, etc.) that each share a single Linux network namespace. Each group gets its own isolated `localhost`, so two dev servers can both run on `localhost:3000` in different groups without conflict. Docker containers, browser tabs, and cookies are all group-aware.

```
Group 1 (ws 1-10)            Group 2 (ws 11-20)           Group 3 (ws 21-30)
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│  localhost:3000  │         │  localhost:3000  │         │  localhost:3000  │
│  localhost:5432  │         │  localhost:8080  │         │  localhost:5432  │
│                  │         │                  │         │                  │
│  ── veth ──────  │         │  ── veth ──────  │         │  ── veth ──────  │
└────────┬─────────┘         └────────┬─────────┘         └────────┬─────────┘
         │                            │                            │
         └────────────────────────────┼────────────────────────────┘
                                      │
                              Host (NAT / internet)
```

Because isolation happens at the network layer, your projects run exactly as they would normally &mdash; same ports, same auth redirects, same cookies, same localStorage, same Docker setup. No rebuilds, no per-project dev configs, no workarounds. You just work in a different workspace group.

Additional features for [Omarchy](https://github.com/nicknisi/omarchy) users:

- **Workspace notifications** &mdash; prepends the workspace number to notifications, so you know _which group_ Claude Code just finished in
- **Group overlay** &mdash; keybind-triggered preview showing which workspace groups are active and what applications are running in each
- **Waybar integration** &mdash; persistent workspace group indicators for quick at-a-glance navigation

## Usage

Dedicate one workspace group per project. Everything inside a group &mdash; terminals, editor, browser tabs, dev servers, Docker containers &mdash; shares the same isolated `localhost`. Switch groups to switch projects.

**Example: working on three projects in parallel**

1. **Group 1 (ws 1-10)** &mdash; T3 Chat
   - ws 1: terminal running Claude Code
   - ws 2: editor with the codebase open
   - ws 3: browser on `localhost:3000` (auth, cookies, sessions all scoped to this group)

2. **Group 2 (ws 11-20)** &mdash; Lawn
   - ws 1: terminal running the dev server
   - ws 2: editor
   - ws 3: browser on `localhost:3000` (no conflict with Group 1)

3. **Group 3 (ws 21-30)** &mdash; FS2 CLI
   - ws 1: terminal running tests
   - ws 2: editor

Switch between groups with `SUPER+ALT+1-3`. Each group is its own self-contained environment &mdash; no port collisions, no cookie conflicts, no hunting through terminal tabs to figure out which project just finished.

**Omarchy users:** When Claude Code finishes a task, the notification includes the workspace number (e.g. `[11] Task complete`) so you know it came from Group 2 without having to hunt through tabs. The group overlay lets you glance at all active groups and their windows without leaving your current workspace.

## Install

Arch Linux:

```bash
git clone https://github.com/Dillpickleschmidt/hyprflow.git
cd hyprflow
makepkg -si
```

Then run the interactive installer:

```bash
hyprflow-install
```

This walks you through enabling each feature:

| Feature             | Description                                        |
| ------------------- | -------------------------------------------------- |
| Namespace isolation | Core daemon + terminal wrapping                    |
| Browser sandboxing  | Per-group browser profiles via firejail            |
| Docker runtime      | OCI runtime wrapper for container isolation        |
| Ghostty override    | Disables single-instance mode                      |
| Workspace groups    | Keybinds for group-based navigation                |
| Group overlay       | Visual workspace group preview (Omarchy)           |
| Notifications       | Workspace-numbered notification proxy (Omarchy)    |
| Waybar              | Persistent workspace indicators (Omarchy)          |

Reboot after setup, or restart Hyprland, Docker, and your browsers individually.

> [!IMPORTANT]
> Docker containers created before installation will need to be re-created. Browser profiles are cloned from your existing profile on first launch per group, preserving login sessions and extensions.

To undo everything: `hyprflow-uninstall` and reboot.

### Dependencies

- Hyprland
- `jq`, `socat`, `iproute2`, `iptables`
- `firejail`, `rsync` (browser sandboxing)
- `gum` (interactive installer)
- `python-gobject` + `gtk4-layer-shell` (group overlay, optional)
- `python-dbus` (notifications, optional)

## Configuration

Defaults live at `/etc/hypr-devns.conf`. Override per-user at `~/.config/hypr-devns.conf`:

```bash
DEVNS_WORKSPACES=all          # "all" or comma-separated workspace IDs
DEVNS_DNS="9.9.9.9 1.1.1.1"  # DNS servers inside namespaces
DEVNS_WAN_IFACE=""            # WAN interface for NAT (auto-detected if empty)
GROUP_OVERLAY=true            # Enable group overlay widget (requires restart)
DEVNS_BROWSERS=""             # Browsers to sandbox (e.g. "chromium helium-browser firefox")
DEVNS_SLOTS_PER_GROUP=5       # Workspace slots shown per group in waybar (1-10)
```

If WAN auto-detection fails (multiple default routes, VPN), set `DEVNS_WAN_IFACE` explicitly. Check with `ip route show default`.

## Architecture

### Namespace lifecycle

The daemon (`hypr-devns-daemon`) listens to Hyprland IPC and lazily creates one namespace per workspace group (10 workspaces per group). Each namespace gets:

- A veth pair connecting it to the host
- Its own IP (`10.200.<group>.2/24`)
- NAT rules for outbound internet
- DNS config via `/etc/netns/`
- IPv6 disabled (dev servers typically bind to `127.0.0.1` only)

`hypr-devns-exec` launches commands inside the current workspace group's namespace. Apps started from the terminal or app launcher enter the namespace automatically.

### Browser sandboxing

Browsers are single-instance processes that can't be moved between namespaces. Hyprflow uses **firejail** to launch each browser directly inside the workspace group's network namespace with a separate profile directory:

```
firejail --noprofile --netns=hyprns_N <browser> --user-data-dir=~/.config/hyprflow/browsers/<browser>-wgN
```

On first launch per group, the base browser profile is cloned (via `rsync`) with cache and localhost-specific storage excluded. This preserves login sessions, bookmarks, passwords, and extensions while ensuring localStorage, IndexedDB, Service Workers, and cookies are fully isolated per workspace group.

Supported browsers: Chromium, Helium, Chrome, Brave, Vivaldi, Edge, Firefox, LibreWolf, Floorp, Zen.

### Docker integration

`hypr-devns-runc` is an OCI runtime wrapper registered as the default Docker runtime. On container create, it patches the container config to join the active workspace group's network namespace. One daemon, shared image/build cache, isolated networking.

**Compose:** A `docker` wrapper sets `COMPOSE_PROJECT_NAME` to `<dir>-wg<id>` so group 1 and group 2 get independent container sets. Port publishing (`ports:`) is stripped since it's redundant inside namespaces and would conflict globally.

### Special cases

| App type | Problem                                       | Solution                                              |
| -------- | --------------------------------------------- | ----------------------------------------------------- |
| Browsers | Single-instance process, shared across groups | Firejail sandboxing with per-group profiles           |
| Ghostty  | `--gtk-single-instance=true` hardcoded        | Desktop file override disabling single-instance       |
| Docker   | Daemon starts before workspace context exists | OCI runtime wrapper patches netns at container create |

## Caveats

- **IPv6 disabled in namespaces** &mdash; Dev servers typically bind to `127.0.0.1` only, but Chromium's built-in DNS resolves `localhost` to both `127.0.0.1` and `::1`. IPv6 is disabled inside namespaces to prevent connection failures.
- **Docker is global** &mdash; The runtime is registered as the default OCI runtime, affecting all containers. Revert with `hyprflow-uninstall`.
- **Port publishing stripped** &mdash; `docker compose` `ports:` directives are removed (redundant in namespaces, would conflict globally). Use `docker run -p` directly on the host if you need external access.
- **Profile sync is one-directional** &mdash; Each browser launch syncs your main browser profile (e.g. `~/.config/chromium`) into the group's copy, so changes like new saved passwords or bookmarks automatically propagate to all groups. Localhost-specific storage stays isolated per group. Non-localhost changes made within a group (e.g. logging into a new site) will be overwritten by your main profile on next launch.
- **Container state** &mdash; Group mapping is cached in `/run/` (lost on reboot). Containers created before installation need to be recreated.

<details>
<summary><strong>Docker edge cases</strong></summary>

1. `docker stats` shows zero network counters for all but the most recently started container per group.
2. `docker network disconnect`/`connect` on a running container may fail.
3. Cross-network DNS resolution may not work for containers on separate Docker networks in the same group.
4. `--network=none` containers add ~5s delay to the next container start in that group.
5. Container starts are serialized per group (~200-500ms overhead each).

</details>

## License

Apache 2.0 &mdash; see [LICENSE](LICENSE) for details.
