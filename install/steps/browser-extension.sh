# Step: Browser extension

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

step_browser_extension() {
    info "Configuring browser extensions..."

    # Auto-detect installed browsers
    local -a detected=()
    local -a detected_labels=()
    command -v chromium &>/dev/null && detected+=("chromium") && detected_labels+=("Chromium")
    command -v helium-browser &>/dev/null && detected+=("helium") && detected_labels+=("Helium")
    command -v zen-browser &>/dev/null && detected+=("zen") && detected_labels+=("Zen")

    if [[ ${#detected[@]} -eq 0 ]]; then
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

    # Chromium
    if echo "$selected_browsers" | grep -qF "Chromium"; then
        add_load_extension "$DEVNS_CHROMIUM_FLAGS" "Chromium"
        add_host_app "chromium"
        manifest_add_browser "Chromium"
    fi

    # Helium
    if echo "$selected_browsers" | grep -qF "Helium"; then
        add_load_extension "$DEVNS_HELIUM_FLAGS" "Helium"
        add_host_app "helium-browser"
        manifest_add_browser "Helium"
    fi

    # Zen
    if echo "$selected_browsers" | grep -qF "Zen"; then
        local zen_policies_dir
        if zen_policies_dir=$(resolve_path "Zen browser policies directory" \
            "$(dirname "$DEVNS_ZEN_POLICIES")" \
            "/usr/lib/zen-browser/distribution"); then

            local zen_policies="${zen_policies_dir}/policies.json"
            if [[ -f "$zen_policies" ]] && grep -q 'hypr-devns@localhost' "$zen_policies" 2>/dev/null; then
                info "Zen: extension already configured"
            else
                local ext_policy="{\"ExtensionSettings\":{\"hypr-devns@localhost\":{\"installation_mode\":\"normal_installed\",\"install_url\":\"file:///${DEVNS_FIREFOX_EXTENSION_DIR}/\"}}}"
                if [[ -f "$zen_policies" ]]; then
                    local merged
                    merged=$(jq --argjson ext "$ext_policy" '.policies = (.policies // {}) * $ext' "$zen_policies")
                    echo "$merged" | sudo tee "$zen_policies" > /dev/null
                else
                    echo "{\"policies\": ${ext_policy}}" | sudo tee "$zen_policies" > /dev/null
                fi
                success "Zen: added extension policy"
            fi
            add_host_app "zen-browser"
            manifest_add_browser "Zen"
            manifest_set_path "zen_policies" "$zen_policies"
        fi
    fi
}
