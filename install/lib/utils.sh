# utils.sh — shared helpers for hyprflow-install

# ─── Logging ─────────────────────────────────────────────────

info()    { printf "  %s\n" "$1"; }
success() { printf "  \033[32m%s\033[0m\n" "$1"; }
warn()    { printf "  \033[33m%s\033[0m\n" "$1"; }

# ─── Shared state ────────────────────────────────────────────

MODE=""
AUTOSTART_FILE=""
BINDINGS_FILE=""
ANIMATIONS_FILE=""
NEED_SOURCE_INSTRUCTIONS=false

# ─── Path resolution ────────────────────────────────────────

resolve_path() {
    local description="$1"
    shift
    for path in "$@"; do
        if [[ -f "$path" || -d "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    local user_path
    user_path=$(gum input --header "Could not find: $description" \
                          --placeholder "/path/to/file")
    if [[ -n "$user_path" ]] && [[ -e "$user_path" ]]; then
        echo "$user_path"
        return 0
    elif [[ -n "$user_path" ]]; then
        warn "Path does not exist: $user_path"
    fi
    warn "Skipping: no valid path for $description"
    return 1
}

has_feature() {
    echo "$1" | grep -qF "$2"
}

# ─── Manifest ───────────────────────────────────────────────

MANIFEST_FILE="$HOME/.local/share/hyprflow/install-manifest.json"
MANIFEST='{}'

manifest_set() {
    MANIFEST=$(echo "$MANIFEST" | jq --arg k "$1" --arg v "$2" '. + {($k): $v}')
}

manifest_add_feature() {
    MANIFEST=$(echo "$MANIFEST" | jq --arg f "$1" '.features = ((.features // []) + [$f] | unique)')
}

manifest_add_file() {
    MANIFEST=$(echo "$MANIFEST" | jq --arg f "$1" '.created_files = ((.created_files // []) + [$f] | unique)')
}

manifest_add_browser() {
    MANIFEST=$(echo "$MANIFEST" | jq --arg b "$1" '.browsers = ((.browsers // []) + [$b] | unique)')
}

manifest_set_path() {
    MANIFEST=$(echo "$MANIFEST" | jq --arg k "$1" --arg v "$2" '.paths = ((.paths // {}) + {($k): $v})')
}

manifest_write() {
    mkdir -p "$(dirname "$MANIFEST_FILE")"
    echo "$MANIFEST" | jq . > "$MANIFEST_FILE"
}

ensure_hyprflow_source() {
    local snippet="$1"
    local anchor="${2:-}"
    local conf="${DEVNS_HYPRLAND_CONF:-$HOME/.config/hypr/hyprland.conf}"

    if [[ ! -f "$conf" ]]; then
        NEED_SOURCE_INSTRUCTIONS=true
        return 0
    fi

    local snippet_path="${snippet/#$HOME/~}"
    local source_line="source = $snippet_path"
    if grep -qxF "$source_line" "$conf" 2>/dev/null; then
        return 0
    fi

    if [[ -n "$anchor" ]] && grep -qxF "$anchor" "$conf" 2>/dev/null; then
        sed -i "\|^${anchor}$|i $source_line" "$conf"
    else
        cat >> "$conf" <<EOF

# Hyprflow user-level configuration
$source_line
EOF
    fi
    success "Hyprland: sourcing $snippet_path"
}

resolve_shared_paths() {
    # Always write Hyprflow's generated Hyprland configuration to Hyprflow-owned
    # snippets. On Omarchy this avoids touching ~/.local/share/omarchy/default/*
    # and keeps large generated keybind blocks out of Omarchy's user bindings file.
    mkdir -p "$(dirname "$DEVNS_HF_AUTOSTART")"
    touch "$DEVNS_HF_AUTOSTART" "$DEVNS_HF_BINDINGS"
    AUTOSTART_FILE="$DEVNS_HF_AUTOSTART"
    BINDINGS_FILE="$DEVNS_HF_BINDINGS"
    ANIMATIONS_FILE="$DEVNS_HF_ANIMATIONS"
    manifest_add_file "$DEVNS_HF_AUTOSTART"
    manifest_add_file "$DEVNS_HF_BINDINGS"

    ensure_hyprflow_source "$DEVNS_HF_AUTOSTART" 'source = ~/.config/hypr/autostart.conf'
    ensure_hyprflow_source "$DEVNS_HF_BINDINGS"
}
