#!/bin/bash
# -----------------------------------------------------------------------------
# Service Optimizer
# -----------------------------------------------------------------------------
# This script optimizes system services based on settings in config.sh.
#
# What it does:
# - Disables specified systemd services to reduce resource usage and boot time.
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

# Disables specified systemd services
disable_services() {
    log_info "Disabling specified systemd services..."

    for service in "${SERVICES_TO_DISABLE[@]}"; do
        if systemctl is-enabled --quiet "$service"; then
            log_info "Disabling and masking service: $service..."
            sudo systemctl disable "$service" > /dev/null
            sudo systemctl mask "$service" > /dev/null
            log_success "Service '$service' disabled and masked."
        else
            log_info "Service '$service' is already disabled or does not exist. Skipping."
        fi
    done
    log_success "Service optimization complete."
}

# --- Execution ---
echo "🚀 Running Service Optimizer..."

disable_services

echo "✅ Service optimization complete."
