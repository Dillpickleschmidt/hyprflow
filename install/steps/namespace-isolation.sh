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

    # Terminal wrapping needs to affect user-defined app binds that reference
    # $terminal. On Omarchy, ~/.config/hypr/bindings.conf is the documented
    # user override file, so edit only that file (never Omarchy defaults).
    local terminal_bindings_file="$BINDINGS_FILE"
    [[ "$MODE" == "omarchy" ]] && terminal_bindings_file="$DEVNS_BINDINGS"
    manifest_set_path "terminal_bindings_file" "$terminal_bindings_file"

    wrap_var() {
        local var="$1" label="$2"
        if grep -q "^${var} = hypr-devns-exec " "$terminal_bindings_file" 2>/dev/null; then
            info "$label wrapping: already configured"
        elif grep -q "^${var} = " "$terminal_bindings_file" 2>/dev/null; then
            sed -i "s|^${var} = |${var} = hypr-devns-exec |" "$terminal_bindings_file"
            success "$label wrapping: configured in ${terminal_bindings_file/$HOME/~}"
        else
            info "$label wrapping: ${var} binding not found, skipping"
        fi
    }

    wrap_var '$terminal' Terminal
    wrap_var '$browser' Browser

    manifest_add_feature "namespace_isolation"

    # Walker/Elephant (Omarchy only)
    if [[ "$MODE" == "omarchy" ]]; then
        mkdir -p "$(dirname "$DEVNS_ELEPHANT")"
        touch "$DEVNS_ELEPHANT"
        python - "$DEVNS_ELEPHANT" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
lines = path.read_text().splitlines()
setting = 'launch_prefix = "hypr-devns-exec uwsm-app --"'

# Remove existing launch_prefix entries anywhere, including stale entries inside tables.
lines = [line for line in lines if not line.strip().startswith('launch_prefix')]

# Insert as a top-level key before the first TOML table.
insert_at = next((i for i, line in enumerate(lines) if line.lstrip().startswith('[')), len(lines))
lines.insert(insert_at, setting)
path.write_text('\n'.join(lines) + '\n')
PY
        success "Walker: configured launch_prefix"
    fi
}
