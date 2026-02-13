# devns-common.sh — shared constants and utilities for hypr-devns scripts
# Source this file: . /usr/share/hypr-workflow/lib/devns-common.sh

# Load config (system then user override)
[ -f /etc/hypr-devns.conf ] && . /etc/hypr-devns.conf
[ -f "$HOME/.config/hypr-devns.conf" ] && . "$HOME/.config/hypr-devns.conf"

DEVNS_DNS="${DEVNS_DNS:-9.9.9.9 1.1.1.1}"
DEVNS_WAN_IFACE="${DEVNS_WAN_IFACE:-}"
DEVNS_WORKSPACES="${DEVNS_WORKSPACES:-all}"
DEVNS_PROXY_PORT=18800
DEVNS_SUBNET_BASE="10.200"

devns_validate_id() {
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "error: invalid namespace id '$1'" >&2
        return 1
    fi
    if [ "$1" -gt 255 ]; then
        echo "error: namespace id '$1' exceeds maximum (255)" >&2
        return 1
    fi
}

devns_ns_name() {
    echo "hyprns_${1}"
}

devns_ns_ip() {
    echo "${DEVNS_SUBNET_BASE}.${1}.2"
}

devns_subnet() {
    echo "${DEVNS_SUBNET_BASE}.${1}"
}

devns_get_wan_iface() {
    if [ -n "$DEVNS_WAN_IFACE" ]; then
        echo "$DEVNS_WAN_IFACE"
    else
        ip route show default | awk '{print $5; exit}'
    fi
}

# Path constants shared between setup and disable
DEVNS_AUTOSTART="$HOME/.config/hypr/autostart.conf"
DEVNS_BINDINGS="$HOME/.config/hypr/bindings.conf"
DEVNS_ELEPHANT="$HOME/.config/elephant/desktopapplications.toml"
DEVNS_GHOSTTY_SYSTEM="/usr/share/applications/com.mitchellh.ghostty.desktop"
DEVNS_GHOSTTY_USER="$HOME/.local/share/applications/com.mitchellh.ghostty.desktop"
DEVNS_CHROMIUM_EXTENSION_DIR="/usr/share/hypr-workflow/extension/chromium"
DEVNS_CHROMIUM_FLAGS="$HOME/.config/chromium-flags.conf"
DEVNS_HELIUM_FLAGS="$HOME/.config/helium-browser-flags.conf"
DEVNS_ZEN_POLICIES="/opt/zen-browser-bin/distribution/policies.json"
DEVNS_DOCKER_DAEMON_JSON="/etc/docker/daemon.json"
