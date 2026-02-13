# Step: Ghostty integration

step_ghostty() {
    info "Configuring Ghostty integration..."

    local ghostty_system
    if ! ghostty_system=$(resolve_path "Ghostty desktop file" \
        "$DEVNS_GHOSTTY_SYSTEM"); then
        return
    fi

    if [[ -f "$DEVNS_GHOSTTY_USER" ]] && grep -q 'gtk-single-instance=false' "$DEVNS_GHOSTTY_USER"; then
        info "Ghostty: already configured"
    else
        mkdir -p "$(dirname "$DEVNS_GHOSTTY_USER")"
        sed 's/--gtk-single-instance=true/--gtk-single-instance=false/g' \
            "$ghostty_system" > "$DEVNS_GHOSTTY_USER"
        success "Ghostty: created desktop override (single-instance disabled)"
    fi

    manifest_add_feature "ghostty"
    manifest_add_file "$DEVNS_GHOSTTY_USER"
}
