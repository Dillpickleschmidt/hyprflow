# Step: Keybinds for workspace groups

step_keybinds() {
    info "Configuring workspace group keybindings..."

    if grep -q 'hypr-workspace-group' "$BINDINGS_FILE" 2>/dev/null; then
        info "Keybindings: already configured"
        return
    fi

    cat >> "$BINDINGS_FILE" << 'WSGROUPS'

# BEGIN hyprflow keybinds
# Workspace groups — groups of 10 workspaces share a network namespace
# SUPER+N switches within current group, SUPER+ALT+N switches group

# Unbind default workspace switching
unbind = SUPER, code:10
unbind = SUPER, code:11
unbind = SUPER, code:12
unbind = SUPER, code:13
unbind = SUPER, code:14
unbind = SUPER, code:15
unbind = SUPER, code:16
unbind = SUPER, code:17
unbind = SUPER, code:18
unbind = SUPER, code:19

# Unbind default move-to-workspace
unbind = SUPER SHIFT, code:10
unbind = SUPER SHIFT, code:11
unbind = SUPER SHIFT, code:12
unbind = SUPER SHIFT, code:13
unbind = SUPER SHIFT, code:14
unbind = SUPER SHIFT, code:15
unbind = SUPER SHIFT, code:16
unbind = SUPER SHIFT, code:17
unbind = SUPER SHIFT, code:18
unbind = SUPER SHIFT, code:19

# Unbind default move-to-workspace-silent
unbind = SUPER SHIFT ALT, code:10
unbind = SUPER SHIFT ALT, code:11
unbind = SUPER SHIFT ALT, code:12
unbind = SUPER SHIFT ALT, code:13
unbind = SUPER SHIFT ALT, code:14
unbind = SUPER SHIFT ALT, code:15
unbind = SUPER SHIFT ALT, code:16
unbind = SUPER SHIFT ALT, code:17
unbind = SUPER SHIFT ALT, code:18
unbind = SUPER SHIFT ALT, code:19

# Unbind ALT group tab bindings (freeing ALT for workspace groups)
unbind = SUPER ALT, code:10
unbind = SUPER ALT, code:11
unbind = SUPER ALT, code:12
unbind = SUPER ALT, code:13
unbind = SUPER ALT, code:14
unbind = SUPER ALT, TAB
unbind = SUPER ALT SHIFT, TAB
unbind = SUPER ALT, mouse_down
unbind = SUPER ALT, mouse_up

# Unbind CTRL+TAB (former workspace, replaced by group tab cycling)
unbind = SUPER CTRL, TAB

# Switch within current workspace group
bindd = SUPER, code:10, Switch to sub-workspace 1, exec, hypr-workspace-group ws 1
bindd = SUPER, code:11, Switch to sub-workspace 2, exec, hypr-workspace-group ws 2
bindd = SUPER, code:12, Switch to sub-workspace 3, exec, hypr-workspace-group ws 3
bindd = SUPER, code:13, Switch to sub-workspace 4, exec, hypr-workspace-group ws 4
bindd = SUPER, code:14, Switch to sub-workspace 5, exec, hypr-workspace-group ws 5
bindd = SUPER, code:15, Switch to sub-workspace 6, exec, hypr-workspace-group ws 6
bindd = SUPER, code:16, Switch to sub-workspace 7, exec, hypr-workspace-group ws 7
bindd = SUPER, code:17, Switch to sub-workspace 8, exec, hypr-workspace-group ws 8
bindd = SUPER, code:18, Switch to sub-workspace 9, exec, hypr-workspace-group ws 9
bindd = SUPER, code:19, Switch to sub-workspace 10, exec, hypr-workspace-group ws 10

# Switch workspace group (network namespace)
bindd = SUPER ALT, code:10, Switch to network group 1, exec, hypr-workspace-group switch 1
bindd = SUPER ALT, code:11, Switch to network group 2, exec, hypr-workspace-group switch 2
bindd = SUPER ALT, code:12, Switch to network group 3, exec, hypr-workspace-group switch 3
bindd = SUPER ALT, code:13, Switch to network group 4, exec, hypr-workspace-group switch 4
bindd = SUPER ALT, code:14, Switch to network group 5, exec, hypr-workspace-group switch 5
bindd = SUPER ALT, code:15, Switch to network group 6, exec, hypr-workspace-group switch 6
bindd = SUPER ALT, code:16, Switch to network group 7, exec, hypr-workspace-group switch 7
bindd = SUPER ALT, code:17, Switch to network group 8, exec, hypr-workspace-group switch 8
bindd = SUPER ALT, code:18, Switch to network group 9, exec, hypr-workspace-group switch 9
bindd = SUPER ALT, code:19, Switch to network group 10, exec, hypr-workspace-group switch 10

# Cycle workspace groups (preserving slot position)
bindd = SUPER ALT, TAB, Next network group, exec, hypr-workspace-group next
bindd = SUPER ALT SHIFT, TAB, Previous network group, exec, hypr-workspace-group prev

# Move window within current group
bindd = SUPER SHIFT, code:10, Move window to sub-workspace 1, exec, hypr-workspace-group move 1
bindd = SUPER SHIFT, code:11, Move window to sub-workspace 2, exec, hypr-workspace-group move 2
bindd = SUPER SHIFT, code:12, Move window to sub-workspace 3, exec, hypr-workspace-group move 3
bindd = SUPER SHIFT, code:13, Move window to sub-workspace 4, exec, hypr-workspace-group move 4
bindd = SUPER SHIFT, code:14, Move window to sub-workspace 5, exec, hypr-workspace-group move 5
bindd = SUPER SHIFT, code:15, Move window to sub-workspace 6, exec, hypr-workspace-group move 6
bindd = SUPER SHIFT, code:16, Move window to sub-workspace 7, exec, hypr-workspace-group move 7
bindd = SUPER SHIFT, code:17, Move window to sub-workspace 8, exec, hypr-workspace-group move 8
bindd = SUPER SHIFT, code:18, Move window to sub-workspace 9, exec, hypr-workspace-group move 9
bindd = SUPER SHIFT, code:19, Move window to sub-workspace 10, exec, hypr-workspace-group move 10

# Move window to another group (keeps relative position)
bindd = SUPER SHIFT ALT, code:10, Move window to group 1, exec, hypr-workspace-group movetogroup 1
bindd = SUPER SHIFT ALT, code:11, Move window to group 2, exec, hypr-workspace-group movetogroup 2
bindd = SUPER SHIFT ALT, code:12, Move window to group 3, exec, hypr-workspace-group movetogroup 3
bindd = SUPER SHIFT ALT, code:13, Move window to group 4, exec, hypr-workspace-group movetogroup 4
bindd = SUPER SHIFT ALT, code:14, Move window to group 5, exec, hypr-workspace-group movetogroup 5
bindd = SUPER SHIFT ALT, code:15, Move window to group 6, exec, hypr-workspace-group movetogroup 6
bindd = SUPER SHIFT ALT, code:16, Move window to group 7, exec, hypr-workspace-group movetogroup 7
bindd = SUPER SHIFT ALT, code:17, Move window to group 8, exec, hypr-workspace-group movetogroup 8
bindd = SUPER SHIFT ALT, code:18, Move window to group 9, exec, hypr-workspace-group movetogroup 9
bindd = SUPER SHIFT ALT, code:19, Move window to group 10, exec, hypr-workspace-group movetogroup 10

# Group tab switching (relocated from ALT to CTRL)
bindd = SUPER CTRL, code:10, Switch to group window 1, changegroupactive, 1
bindd = SUPER CTRL, code:11, Switch to group window 2, changegroupactive, 2
bindd = SUPER CTRL, code:12, Switch to group window 3, changegroupactive, 3
bindd = SUPER CTRL, code:13, Switch to group window 4, changegroupactive, 4
bindd = SUPER CTRL, code:14, Switch to group window 5, changegroupactive, 5
bindd = SUPER CTRL, code:15, Switch to group window 6, changegroupactive, 6
bindd = SUPER CTRL, code:16, Switch to group window 7, changegroupactive, 7
bindd = SUPER CTRL, code:17, Switch to group window 8, changegroupactive, 8
bindd = SUPER CTRL, code:18, Switch to group window 9, changegroupactive, 9
bindd = SUPER CTRL, TAB, Next window in group, changegroupactive, f
bindd = SUPER CTRL SHIFT, TAB, Previous window in group, changegroupactive, b
bindd = SUPER CTRL, mouse_down, Next window in group, changegroupactive, f
bindd = SUPER CTRL, mouse_up, Previous window in group, changegroupactive, b
# END hyprflow keybinds
WSGROUPS

    manifest_add_feature "keybinds"
    success "Keybindings: added workspace group bindings"
}
