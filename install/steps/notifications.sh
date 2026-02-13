# Step: Workspace numbered notifications (Omarchy only)

step_notifications() {
    info "Configuring workspace notifications..."

    manifest_add_feature "notifications"

    if grep -q 'hypr-notif-ws' "$AUTOSTART_FILE" 2>/dev/null; then
        info "Notifications: already configured"
    else
        echo 'exec-once = uwsm-app -- hypr-notif-ws' >> "$AUTOSTART_FILE"
        success "Notifications: added hypr-notif-ws to autostart"
    fi
}
