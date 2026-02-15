# Step: Browser firejail setup

# All supported browsers: label|command
SUPPORTED_BROWSERS=(
    "Chromium|chromium"
    "Helium|helium-browser"
    "Chrome|google-chrome-stable"
    "Brave|brave"
    "Vivaldi|vivaldi-stable"
    "Edge|microsoft-edge-stable"
    "Zen|zen-browser"
    "Firefox|firefox"
    "LibreWolf|librewolf"
    "Floorp|floorp"
)

add_browser() {
    local cmd="$1"
    local config="$HOME/.config/hypr-devns.conf"
    touch "$config"
    if grep -q '^DEVNS_BROWSERS=' "$config" 2>/dev/null; then
        grep '^DEVNS_BROWSERS=' "$config" | grep -qw "$cmd" && return 0
        sed -i "s|^DEVNS_BROWSERS=\"\(.*\)\"|DEVNS_BROWSERS=\"\1 ${cmd}\"|" "$config"
    else
        echo "DEVNS_BROWSERS=\"${cmd}\"" >> "$config"
    fi
}

step_browser_firejail() {
    info "Configuring browser sandboxing..."

    if ! command -v firejail &>/dev/null; then
        warn "firejail is not installed, skipping browser setup"
        return
    fi

    if ! command -v rsync &>/dev/null; then
        warn "rsync is not installed, skipping browser setup"
        return
    fi

    # Auto-detect installed browsers
    local -a detected_labels=()
    local -a detected_cmds=()

    for entry in "${SUPPORTED_BROWSERS[@]}"; do
        IFS='|' read -r label cmd <<< "$entry"
        if command -v "$cmd" &>/dev/null; then
            detected_labels+=("$label")
            detected_cmds+=("$cmd")
        fi
    done

    if [[ ${#detected_labels[@]} -eq 0 ]]; then
        warn "No supported browsers detected, skipping"
        return
    fi

    # Show detected browsers for confirmation
    local preselected
    preselected=$(IFS=,; echo "${detected_labels[*]}")
    local selected_browsers
    selected_browsers=$(gum choose --no-limit \
        --header "Detected browsers (deselect to skip):" \
        --selected "$preselected" \
        "${detected_labels[@]}") || return 0

    if [[ -z "$selected_browsers" ]]; then
        info "No browsers selected, skipping"
        return
    fi

    manifest_add_feature "browser_firejail"

    for i in "${!detected_labels[@]}"; do
        local label="${detected_labels[$i]}"
        echo "$selected_browsers" | grep -qF "$label" || continue

        local cmd="${detected_cmds[$i]}"
        add_browser "$cmd"
        manifest_add_browser "$label"
        success "${label}: configured for firejail sandboxing"
    done
}
