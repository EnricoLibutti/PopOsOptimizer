#!/bin/bash
# -----------------------------------------------------------------------------
# Desktop Optimizer
# -----------------------------------------------------------------------------
# This script optimizes the GNOME desktop environment for a development
# workflow based on settings in config.sh.
#
# What it does:
# - Disables animations for a snappier feel.
# - Configures workspace behavior.
# - Sets preferred fonts.
# - Disables GNOME Tracker services to save resources.
# -----------------------------------------------------------------------------

set -e

# --- Load Configuration ---
source "$(dirname "$0")/config.sh"

# --- Helper Functions ---
log_info() {
    echo "[INFO] $1"
}

log_success() {
    echo "[SUCCESS] $1"
}

log_warning() {
    echo "[WARNING] $1"
}

# --- Main Functions ---

# Disables or enables desktop animations
configure_animations() {
    local target_animation_state=$([ "$DISABLE_DESKTOP_ANIMATIONS" = true ] && echo "false" || echo "true")

    log_info "Configuring desktop animations..."

    # Check current state before applying
    if [[ "$(gsettings get org.gnome.desktop.interface enable-animations)" != "$target_animation_state" ]]; then
        gsettings set org.gnome.desktop.interface enable-animations "$target_animation_state"
        log_info "Set org.gnome.desktop.interface enable-animations to $target_animation_state."
    fi
    if [[ "$(gsettings get org.gnome.desktop.interface gtk-enable-animations)" != "$target_animation_state" ]]; then
        gsettings set org.gnome.desktop.interface gtk-enable-animations "$target_animation_state"
        log_info "Set org.gnome.desktop.interface gtk-enable-animations to $target_animation_state."
    fi
    # Pop Shell specific animations
    if gsettings list-keys org.gnome.shell.extensions.dash-to-dock &>/dev/null; then
        if [[ "$(gsettings get org.gnome.shell.extensions.dash-to-dock animate-show-apps)" != "$target_animation_state" ]]; then
            gsettings set org.gnome.shell.extensions.dash-to-dock animate-show-apps "$target_animation_state"
            log_info "Set org.gnome.shell.extensions.dash-to-dock animate-show-apps to $target_animation_state."
        fi
        if [[ "$(gsettings get org.gnome.shell.extensions.dash-to-dock animation-time)" != "0" ]]; then
            gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0
            log_info "Set org.gnome.shell.extensions.dash-to-dock animation-time to 0."
        fi
    fi

    log_success "Desktop animations configured."
}

# Configures the number of static workspaces
configure_workspaces() {
    log_info "Setting number of static workspaces to $NUM_WORKSPACES..."
    if [[ "$(gsettings get org.gnome.mutter dynamic-workspaces)" != "false" ]]; then
        gsettings set org.gnome.mutter dynamic-workspaces false
        log_info "Disabled dynamic workspaces."
    fi
    if [[ "$(gsettings get org.gnome.desktop.wm.preferences num-workspaces)" != "$NUM_WORKSPACES" ]]; then
        gsettings set org.gnome.desktop.wm.preferences num-workspaces "$NUM_WORKSPACES"
        log_info "Set num-workspaces to $NUM_WORKSPACES."
    fi
    log_success "Workspaces configured."
}

# Sets the monospace font
set_monospace_font() {
    log_info "Setting monospace font to '$MONOSPACE_FONT'..."
    if [[ "$(gsettings get org.gnome.desktop.interface monospace-font-name)" != "'$MONOSPACE_FONT'" ]]; then
        gsettings set org.gnome.desktop.interface monospace-font-name "$MONOSPACE_FONT"
        log_success "Monospace font set to '$MONOSPACE_FONT'."
    else
        log_info "Monospace font is already set to '$MONOSPACE_FONT'."
    fi
}

# Disables GNOME Tracker services
disable_tracker_services() {
    if [ "$DISABLE_TRACKER_SERVICES" = true ]; then
        log_info "Disabling GNOME Tracker services..."
        systemctl --user mask tracker-store.service
        systemctl --user mask tracker-miner-fs.service
        systemctl --user mask tracker-extract.service
        systemctl --user stop tracker-store.service 2>/dev/null || true
        systemctl --user stop tracker-miner-fs.service 2>/dev/null || true
        log_success "GNOME Tracker services disabled."
    else
        log_info "GNOME Tracker services will remain enabled."
    fi
}

# --- Execution ---
echo "🚀 Running Desktop Optimizer..."

configure_animations
configure_workspaces
set_monospace_font
disable_tracker_services

# Other desktop settings (hardcoded for now, can be moved to config.sh if needed)
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
gsettings set org.gnome.desktop.wm.preferences focus-mode 'click'
gsettings set org.gnome.desktop.wm.preferences auto-raise false
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.session idle-delay 1800
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'
gsettings set org.gnome.desktop.default-applications.terminal exec 'gnome-terminal'
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gnome.nautilus.preferences show-directory-item-counts 'always'
gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'
gsettings set org.gnome.desktop.notifications show-banners false
gsettings set org.gnome.desktop.notifications show-in-lock-screen false

# Pop Shell specific settings (hardcoded for now)
if gsettings list-keys org.gnome.shell.extensions.pop-shell &>/dev/null; then
    gsettings set org.gnome.shell.extensions.pop-shell tile-by-default true
    gsettings set org.gnome.shell.extensions.pop-shell show-title false
    gsettings set org.gnome.shell.extensions.pop-shell smart-gaps true
    gsettings set org.gnome.shell.extensions.pop-shell gap-inner 2
    gsettings set org.gnome.shell.extensions.pop-shell gap-outer 2
fi

log_success "Desktop optimization complete."
