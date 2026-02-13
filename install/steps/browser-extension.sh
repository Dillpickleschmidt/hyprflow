# Step: Browser extension

# Chromium-based browsers: label|command|flags_file
CHROMIUM_BROWSERS=(
    "Chromium|chromium|$DEVNS_CHROMIUM_FLAGS"
    "Helium|helium-browser|$DEVNS_HELIUM_FLAGS"
    "Chrome|google-chrome-stable|$DEVNS_CHROME_FLAGS"
    "Brave|brave|$DEVNS_BRAVE_FLAGS"
    "Vivaldi|vivaldi-stable|$DEVNS_VIVALDI_FLAGS"
    "Edge|microsoft-edge-stable|$DEVNS_EDGE_FLAGS"
)

# Firefox-based browsers: label|command|policies_path
FIREFOX_BROWSERS=(
    "Zen|zen-browser|$DEVNS_ZEN_POLICIES"
    "Firefox|firefox|$DEVNS_FIREFOX_POLICIES"
    "LibreWolf|librewolf|$DEVNS_LIBREWOLF_POLICIES"
    "Floorp|floorp|$DEVNS_FLOORP_POLICIES"
)

add_host_app() {
    local cmd="$1"
    local config="$HOME/.config/hypr-devns.conf"
    touch "$config"
    if grep -q '^DEVNS_HOST_APPS=' "$config" 2>/dev/null; then
        grep '^DEVNS_HOST_APPS=' "$config" | grep -qw "$cmd" && return 0
        sed -i "s|^DEVNS_HOST_APPS=\"\(.*\)\"|DEVNS_HOST_APPS=\"\1 ${cmd}\"|" "$config"
    else
        echo "DEVNS_HOST_APPS=\"${cmd}\"" >> "$config"
    fi
}

add_load_extension() {
    local flags_file="$1"
    local label="$2"
    if [[ ! -f "$flags_file" ]]; then
        echo "--load-extension=${DEVNS_CHROMIUM_EXTENSION_DIR}" > "$flags_file"
        success "${label}: created with --load-extension"
        return
    fi
    if grep -qF "${DEVNS_CHROMIUM_EXTENSION_DIR}" "$flags_file" 2>/dev/null; then
        info "${label}: extension already configured"
        return
    fi
    if grep -qF -- '--load-extension=' "$flags_file"; then
        sed -i "s|--load-extension=\([^ ]*\)|--load-extension=\1,${DEVNS_CHROMIUM_EXTENSION_DIR}|" "$flags_file"
        success "${label}: appended to existing --load-extension"
    else
        echo "--load-extension=${DEVNS_CHROMIUM_EXTENSION_DIR}" >> "$flags_file"
        success "${label}: added --load-extension"
    fi
}

add_firefox_extension() {
    local label="$1"
    local cmd="$2"
    shift 2
    # Remaining args are policies dir candidates
    local policies_dir
    if policies_dir=$(resolve_path "${label} browser policies directory" "$@"); then
        local policies_file="${policies_dir}/policies.json"
        if [[ -f "$policies_file" ]] && grep -q 'hypr-devns@localhost' "$policies_file" 2>/dev/null; then
            info "${label}: extension already configured"
        else
            local ext_policy="{\"ExtensionSettings\":{\"hypr-devns@localhost\":{\"installation_mode\":\"normal_installed\",\"install_url\":\"file:///${DEVNS_FIREFOX_EXTENSION_DIR}/\"}}}"
            if [[ -f "$policies_file" ]]; then
                local merged
                merged=$(jq --argjson ext "$ext_policy" '.policies = (.policies // {}) * $ext' "$policies_file")
                echo "$merged" | sudo tee "$policies_file" > /dev/null
            else
                echo "{\"policies\": ${ext_policy}}" | sudo tee "$policies_file" > /dev/null
            fi
            success "${label}: added extension policy"
        fi
        add_host_app "$cmd"
        manifest_add_browser "$label"
        manifest_set_path "${label,,}_policies" "$policies_file"
    fi
}

step_browser_extension() {
    info "Configuring browser extensions..."

    # Auto-detect installed browsers
    local -a detected_labels=()
    local -a detected_entries=()
    local -a detected_types=()

    for entry in "${CHROMIUM_BROWSERS[@]}"; do
        IFS='|' read -r label cmd _ <<< "$entry"
        if command -v "$cmd" &>/dev/null; then
            detected_labels+=("$label")
            detected_entries+=("$entry")
            detected_types+=("chromium")
        fi
    done

    for entry in "${FIREFOX_BROWSERS[@]}"; do
        IFS='|' read -r label cmd _ <<< "$entry"
        if command -v "$cmd" &>/dev/null; then
            detected_labels+=("$label")
            detected_entries+=("$entry")
            detected_types+=("firefox")
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

    manifest_add_feature "browser_extension"

    for i in "${!detected_labels[@]}"; do
        local label="${detected_labels[$i]}"
        echo "$selected_browsers" | grep -qF "$label" || continue

        IFS='|' read -r _ cmd data <<< "${detected_entries[$i]}"

        if [[ "${detected_types[$i]}" == "chromium" ]]; then
            add_load_extension "$data" "$label"
            add_host_app "$cmd"
            manifest_add_browser "$label"
        else
            # Firefox-based: try constant path + standard /usr/lib location
            add_firefox_extension "$label" "$cmd" \
                "$(dirname "$data")" "/usr/lib/${cmd}/distribution"
        fi
    done
}
