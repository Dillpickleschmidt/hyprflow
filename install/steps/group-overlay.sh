# Step: Group preview widget (Omarchy only)

step_group_overlay() {
    info "Configuring group preview widget..."

    local config_file="$HOME/.config/hypr-devns.conf"
    if [[ ! -f "$config_file" ]]; then
        mkdir -p "$HOME/.config"
        cp /etc/hypr-devns.conf "$config_file"
    fi

    manifest_add_feature "group_overlay"

    if grep -q '^GROUP_OVERLAY=' "$config_file" 2>/dev/null; then
        if grep -q '^GROUP_OVERLAY=true' "$config_file" 2>/dev/null; then
            info "Group overlay: already enabled"
        else
            sed -i 's/^GROUP_OVERLAY=.*/GROUP_OVERLAY=true/' "$config_file"
            success "Group overlay: enabled"
        fi
    else
        echo 'GROUP_OVERLAY=true' >> "$config_file"
        success "Group overlay: enabled"
    fi

    # Add to autostart
    if grep -q 'hypr-group-overlay' "$AUTOSTART_FILE" 2>/dev/null; then
        info "Group overlay: already in autostart"
    else
        echo 'exec-once = hypr-group-overlay' >> "$AUTOSTART_FILE"
        success "Group overlay: added to autostart"
    fi

    # Overlay trigger keybindings + layer rule
    if grep -q 'hypr-group-overlay' "$BINDINGS_FILE" 2>/dev/null; then
        info "Group overlay: keybindings already configured"
    else
        cat >> "$BINDINGS_FILE" << 'OVERLAY'

# BEGIN hypr-group-overlay
# Group tab overlay — pure visual side effect
layerrule = no_anim on, match:namespace hypr-group-overlay
bindn = SUPER, Alt_L, exec, kill -USR2 $(cat $XDG_RUNTIME_DIR/hypr-group-overlay.pid 2>/dev/null) 2>/dev/null || hypr-group-overlay
bindn = ALT, Super_L, exec, kill -USR2 $(cat $XDG_RUNTIME_DIR/hypr-group-overlay.pid 2>/dev/null) 2>/dev/null || hypr-group-overlay
# END hypr-group-overlay
OVERLAY
        success "Group overlay: added keybindings"
    fi

    # Disable built-in groupbar
    local looknfeel="$HOME/.config/hypr/looknfeel.conf"
    if [[ -f "$looknfeel" ]]; then
        if grep -q '# BEGIN hypr-group-overlay groupbar' "$looknfeel" 2>/dev/null || grep -qE '^\s*groupbar\s*\{' "$looknfeel" 2>/dev/null; then
            info "Group overlay: groupbar already configured"
        else
            cat >> "$looknfeel" << 'GROUPBAR'

# BEGIN hypr-group-overlay groupbar
# Disable built-in groupbar (replaced by hypr-group-overlay)
group {
    groupbar {
        enabled = false
    }
}
# END hypr-group-overlay groupbar
GROUPBAR
            success "Group overlay: disabled built-in groupbar"
        fi
    fi
}
