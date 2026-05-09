# Step: Workspace group animations

step_animations() {
    info "Configuring workspace group animations..."

    manifest_add_feature "animations"
    manifest_add_file "$ANIMATIONS_FILE"
    ensure_hyprflow_source "$ANIMATIONS_FILE" 'source = ~/.config/hypr/looknfeel.conf'

    cat > "$ANIMATIONS_FILE" <<'ANIMATIONS'
# Hyprflow workspace animation defaults
# Normal workspace switches are instant; hypr-workspace-group temporarily enables
# vertical slide animations around workspace-group transitions.
animations {
    animation = workspaces, 0, 0, ease
}
ANIMATIONS

    success "Animations: group transitions slide vertically; normal workspace switches stay instant"
}
