# Step: Network namespace isolation

step_namespace_isolation() {
    info "Configuring network namespace isolation..."

    # User config
    if [[ ! -f "$HOME/.config/hypr-devns.conf" ]]; then
        mkdir -p "$HOME/.config"
        cp /etc/hypr-devns.conf "$HOME/.config/hypr-devns.conf"
        success "Created ~/.config/hypr-devns.conf"
    else
        info "~/.config/hypr-devns.conf already exists"
    fi

    # Autostart daemon
    if grep -q 'hypr-devns-daemon' "$AUTOSTART_FILE" 2>/dev/null; then
        info "Autostart: already configured"
    else
        echo 'exec-once = hypr-devns-daemon' >> "$AUTOSTART_FILE"
        success "Autostart: added hypr-devns-daemon"
    fi

    # Terminal wrapping
    if grep -q 'hypr-devns-exec' "$BINDINGS_FILE" 2>/dev/null; then
        info "Terminal wrapping: already configured"
    elif grep -q '^\$terminal = ' "$BINDINGS_FILE" 2>/dev/null; then
        sed -i 's/^\$terminal = /\$terminal = hypr-devns-exec /' "$BINDINGS_FILE"
        success "Terminal wrapping: wrapped \$terminal with hypr-devns-exec"
    else
        info "Terminal wrapping: \$terminal binding not found, skipping"
    fi

    manifest_add_feature "namespace_isolation"

    # Walker/Elephant (Omarchy only)
    if [[ "$MODE" == "omarchy" ]]; then
        if [[ -f "$DEVNS_ELEPHANT" ]]; then
            if grep -q 'hypr-devns-exec' "$DEVNS_ELEPHANT" 2>/dev/null; then
                info "Walker: already configured"
            elif grep -q '^launch_prefix' "$DEVNS_ELEPHANT" 2>/dev/null; then
                sed -i 's|^launch_prefix.*|launch_prefix = "hypr-devns-exec uwsm-app --"|' "$DEVNS_ELEPHANT"
                success "Walker: replaced existing launch_prefix"
            else
                echo 'launch_prefix = "hypr-devns-exec uwsm-app --"' >> "$DEVNS_ELEPHANT"
                success "Walker: added launch_prefix"
            fi
        else
            mkdir -p "$(dirname "$DEVNS_ELEPHANT")"
            echo 'launch_prefix = "hypr-devns-exec uwsm-app --"' > "$DEVNS_ELEPHANT"
            success "Walker: created with launch_prefix"
        fi
    fi
}
