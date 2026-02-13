# Step: Waybar modifications (Omarchy only)

step_waybar() {
    info "Configuring Waybar..."

    local waybar_config
    if ! waybar_config=$(resolve_path "Waybar config" \
        "$HOME/.config/waybar/config.jsonc" \
        "$HOME/.config/waybar/config"); then
        return
    fi

    local backup="${waybar_config}.hypr-workflow-backup"

    manifest_add_feature "waybar"
    manifest_set_path "waybar_config" "$waybar_config"
    manifest_set_path "waybar_backup" "$backup"

    # Back up original if we haven't already
    if [[ ! -f "$backup" ]]; then
        cp "$waybar_config" "$backup"
    fi

    local hs_module='."hyprland/workspaces"'
    local current_icons
    current_icons=$(jq -r "${hs_module}.\"format-icons\" | keys | length" "$waybar_config" 2>/dev/null) || current_icons=0

    if [[ "$current_icons" -gt 2 ]] 2>/dev/null; then
        local tmp
        tmp=$(mktemp)
        if jq "${hs_module}.\"format-icons\" = {\"active\": \"󱓻\"}" \
            "$waybar_config" > "$tmp"; then
            mv "$tmp" "$waybar_config"
        else
            rm -f "$tmp"
            return 1
        fi
        success "Waybar: simplified format-icons for dynamic groups"
    else
        info "Waybar: format-icons already simplified"
    fi
}
