#!/bin/bash
# -----------------------------------------------------------------------------
# Boot Optimizer
# -----------------------------------------------------------------------------
# This script optimizes boot time by configuring the GRUB bootloader based
# on settings in config.sh.
#
# What it does:
# - Creates a backup of the current GRUB configuration.
# - Sets the GRUB timeout.
# - Sets the kernel boot parameters.
# - Updates GRUB to apply the changes.
#
# WARNING: Incorrect GRUB settings can prevent your system from booting.
# The default kernel parameters in config.sh are highly specific to an
# AMD Ryzen system. Review them carefully before applying.
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

# Updates the GRUB configuration file
update_grub_config() {
    local grub_config_file="/etc/default/grub"

    # Create a backup of the original file
    if [ ! -f "${grub_config_file}.bak" ]; then
        log_info "Creating a backup of the GRUB config at ${grub_config_file}.bak..."
        sudo cp "$grub_config_file" "${grub_config_file}.bak"
    fi

    log_info "Updating GRUB configuration at $grub_config_file..."

    # Set GRUB_TIMEOUT
    sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=$GRUB_TIMEOUT/" "$grub_config_file"
    log_info "Set GRUB_TIMEOUT to $GRUB_TIMEOUT."

    # Set GRUB_CMDLINE_LINUX_DEFAULT
    # Note: This replaces the entire line. The value from config.sh should be complete.
    sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_CMDLINE_LINUX_DEFAULT\"|" "$grub_config_file"
    log_info "Set GRUB_CMDLINE_LINUX_DEFAULT."
    log_warning "Kernel parameters are advanced settings. Please review them in config.sh."

    # Update GRUB to apply the changes
    log_info "Running update-grub to apply new configuration..."
    sudo update-grub

    log_success "GRUB configuration has been updated."
}

# --- Execution ---
echo "🚀 Running Boot Optimizer..."

update_grub_config

echo "✅ Boot optimization complete. A reboot is required to see the effect."
