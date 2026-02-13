# Step: Docker integration

step_docker() {
    info "Configuring Docker integration..."

    if ! command -v docker &>/dev/null; then
        warn "Docker not found, skipping"
        return
    fi

    if [[ -f "$DEVNS_DOCKER_DAEMON_JSON" ]] && grep -q 'hypr-devns-runc' "$DEVNS_DOCKER_DAEMON_JSON" 2>/dev/null; then
        info "Docker: runtime already configured"
    else
        # Back up original if it exists and we haven't already
        local backup="${DEVNS_DOCKER_DAEMON_JSON}.hyprflow-backup"
        if [[ -f "$DEVNS_DOCKER_DAEMON_JSON" ]] && [[ ! -f "$backup" ]]; then
            sudo cp "$DEVNS_DOCKER_DAEMON_JSON" "$backup"
            manifest_set_path "docker_backup" "$backup"
        fi

        local dns_json
        dns_json=$(echo "$DEVNS_DNS" | jq -R '[split(" ") | .[] | select(. != "")]')
        local devns_runtime
        devns_runtime=$(jq -n --argjson dns "$dns_json" \
            '{"default-runtime":"devns","runtimes":{"devns":{"path":"/usr/bin/hypr-devns-runc"}},"dns":$dns}')

        if [[ -f "$DEVNS_DOCKER_DAEMON_JSON" ]]; then
            local merged
            merged=$(jq --argjson rt "$devns_runtime" '. * $rt' "$DEVNS_DOCKER_DAEMON_JSON")
            echo "$merged" | sudo tee "$DEVNS_DOCKER_DAEMON_JSON" > /dev/null
        else
            sudo mkdir -p "$(dirname "$DEVNS_DOCKER_DAEMON_JSON")"
            echo "$devns_runtime" | sudo tee "$DEVNS_DOCKER_DAEMON_JSON" > /dev/null
        fi
        sudo systemctl restart docker 2>/dev/null || true
        success "Docker: registered devns runtime"
    fi

    manifest_add_feature "docker"
}
