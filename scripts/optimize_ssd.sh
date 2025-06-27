#!/bin/bash
# -----------------------------------------------------------------------------
# SSD Optimizer
# -----------------------------------------------------------------------------
# This script optimizes SSD performance based on settings in config.sh.
#
# What it does:
# - Enables or disables the fstrim.timer for automatic weekly TRIM.
# - Sets the I/O scheduler for NVMe devices.
# - Configures read-ahead for the primary NVMe device.
# - Applies kernel settings to improve file-watching performance.
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

# Enables or disables automatic TRIM
enable_trim() {
    if [ "$ENABLE_AUTOMATIC_TRIM" = true ]; then
        if ! sudo systemctl is-enabled --quiet fstrim.timer; then
            log_info "Enabling automatic weekly TRIM (fstrim.timer)..."
            sudo systemctl enable fstrim.timer
            sudo systemctl start fstrim.timer
            log_success "Automatic TRIM has been enabled."
        else
            log_info "Automatic TRIM is already enabled."
        fi
    else
        if sudo systemctl is-enabled --quiet fstrim.timer; then
            log_info "Disabling automatic weekly TRIM (fstrim.timer)..."
            sudo systemctl disable fstrim.timer
            sudo systemctl stop fstrim.timer
            log_success "Automatic TRIM has been disabled."
        else
            log_info "Automatic TRIM is already disabled."
        fi
    fi
}

# Sets the I/O scheduler for NVMe drives
set_nvme_scheduler() {
    local rules_file="/etc/udev/rules.d/60-nvme-scheduler.rules"
    local rule_content="ACTION==\"add|change\", KERNEL==\"nvme[0-9]*\", ATTR{queue/scheduler}=\"$NVME_IO_SCHEDULER\""

    log_info "Setting NVMe I/O scheduler to '$NVME_IO_SCHEDULER'...
    echo "$rule_content" | sudo tee "$rules_file" > /dev/null
    sudo udevadm control --reload-rules && sudo udevadm trigger
    log_success "NVMe I/O scheduler set to '$NVME_IO_SCHEDULER'."
}

# Sets the read-ahead value for the primary NVMe device
set_nvme_read_ahead() {
    local primary_nvme_device
    primary_nvme_device=$(lsblk -d -o NAME,ROTA | grep 'nvme' | head -n 1 | awk '{print $1}')

    if [[ -z "$primary_nvme_device" ]]; then
        log_warning "No NVMe device found. Skipping read-ahead optimization."
        return
    fi

    log_info "Setting read-ahead for /dev/$primary_nvme_device to ${NVME_READ_AHEAD_KB} KB..."
    sudo blockdev --setra "$NVME_READ_AHEAD_KB" "/dev/$primary_nvme_device"
    log_success "Read-ahead for /dev/$primary_nvme_device set to ${NVME_READ_AHEAD_KB} KB."
}

# Applies kernel settings for file watching
apply_fs_settings() {
    log_info "Applying file system optimization settings for file watchers..."

    for setting in "${FS_SYSCTL_SETTINGS[@]}"; do
        local key
        key=$(echo "$setting" | cut -d'=' -f1 | xargs)

        if sudo grep -q "^$key" /etc/sysctl.conf; then
            sudo sed -i "/^$key/d" /etc/sysctl.conf
        fi

        echo "$setting" | sudo tee -a /etc/sysctl.conf > /dev/null
        log_info "Set: $setting"
    done

    sudo sysctl -p
    log_success "File system settings for watchers have been applied."
}

# --- Execution ---
echo "🚀 Running SSD Optimizer..."

enable_trim
set_nvme_scheduler
set_nvme_read_ahead
apply_fs_settings

echo "✅ SSD optimization complete."
