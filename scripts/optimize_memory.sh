#!/bin/bash
# -----------------------------------------------------------------------------
# Memory Optimizer
# -----------------------------------------------------------------------------
# This script optimizes memory management based on settings in config.sh.
#
# What it does:
# - Applies custom kernel `sysctl` parameters for memory and scheduler.
# - Ensures settings are not duplicated in /etc/sysctl.conf.
# - Reloads sysctl to apply changes immediately.
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

# --- Main Functions ---

# Applies kernel sysctl settings from the config file
apply_memory_settings() {
    log_info "Applying memory optimization settings..."

    for setting in "${MEMORY_SYSCTL_SETTINGS[@]}"; do
        local key
        key=$(echo "$setting" | cut -d'=' -f1 | xargs)

        # Remove any existing line with the same key to avoid duplicates
        if sudo grep -q "^$key" /etc/sysctl.conf; then
            sudo sed -i "/^$key/d" /etc/sysctl.conf
        fi

        # Add the new setting to the end of the file
        echo "$setting" | sudo tee -a /etc/sysctl.conf > /dev/null
        log_info "Set: $setting"
    done

    # Reload sysctl to apply the new settings
    sudo sysctl -p

    log_success "All memory settings have been applied and made persistent."
}

# --- Execution ---
echo "🚀 Running Memory Optimizer..."

apply_memory_settings

echo "✅ Memory optimization complete."
