#!/bin/bash
# -----------------------------------------------------------------------------
# Backup Safety Script
# -----------------------------------------------------------------------------
# This script creates a comprehensive backup of critical system configurations
# before applying any optimizations. It also generates a `restore.sh` script
# within the backup directory for easy rollback.
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

create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$SCRIPT_DIR/$BACKUP_DIR/optimization_backup_$timestamp"

    log_info "Creating backup directory: $backup_path..."
    mkdir -p "$backup_path"

    log_info "Backing up critical configurations..."
    # System configurations
    sudo cp /etc/default/grub "$backup_path/grub.backup" 2>/dev/null || log_warning "GRUB backup failed."
    sudo cp /etc/fstab "$backup_path/fstab.backup" 2>/dev/null || log_warning "FSTAB backup failed."
    sudo cp /etc/sysctl.conf "$backup_path/sysctl.backup" 2>/dev/null || log_warning "SYSCTL backup failed."
    sudo cp /etc/udev/rules.d/60-nvme-scheduler.rules "$backup_path/60-nvme-scheduler.rules.backup" 2>/dev/null || log_warning "NVMe scheduler rules backup failed."
    sudo cp /etc/systemd/system/set-cpu-governor.service "$backup_path/set-cpu-governor.service.backup" 2>/dev/null || log_warning "CPU governor service backup failed."
    sudo cp /etc/systemd/system/nvme-readahead.service "$backup_path/nvme-readahead.service.backup" 2>/dev/null || log_warning "NVMe readahead service backup failed."

    # User configurations
    cp ~/.bashrc "$backup_path/bashrc.backup" 2>/dev/null || log_warning "BASHRC backup failed."
    dconf dump /org/gnome/ > "$backup_path/gnome_settings.backup" 2>/dev/null || log_warning "GNOME settings backup failed."

    # System information
    log_info "Saving pre-optimization system information..."
    cat << EOF > "$backup_path/system_info.txt"
=== SYSTEM INFO BEFORE OPTIMIZATION ===
Date: $(date)
Hostname: $(hostname)
Kernel: $(uname -r)
CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2)
RAM: $(free -h | grep Mem | awk '{print $2}')
GPU: $(lspci | grep VGA)
Boot time: $(systemd-analyze | head -1)
Uptime: $(uptime)
EOF

    # Generate restore script
    log_info "Generating restore script..."
    cat << 'EOF' > "$backup_path/restore.sh"
#!/bin/bash
# Script to restore configurations from this backup

echo "=== RESTORING CONFIGURATIONS ==="
BACKUP_DIR="$(dirname "$0")"

restore_file() {
    local src_file="$1"
    local dest_file="$2"
    local description="$3"
    if [[ -f "$BACKUP_DIR/$src_file" ]]; then
        read -p "Restore $description? (y/n): " confirm
        if [[ $confirm == "y" ]]; then
            sudo cp "$BACKUP_DIR/$src_file" "$dest_file"
            echo "✅ $description restored."
        else
            echo "Skipping $description restore."
        fi
    else
        echo "No backup found for $description. Skipping."
    fi
}

restore_file "grub.backup" "/etc/default/grub" "GRUB configuration"
if [[ -f "$BACKUP_DIR/grub.backup" ]]; then
    read -p "Update GRUB after restoring? (y/n): " update_grub_confirm
    if [[ $update_grub_confirm == "y" ]]; then
        sudo update-grub
        echo "✅ GRUB updated."
    fi
fi

restore_file "fstab.backup" "/etc/fstab" "FSTAB configuration"
restore_file "sysctl.backup" "/etc/sysctl.conf" "SYSCTL configuration"
restore_file "60-nvme-scheduler.rules.backup" "/etc/udev/rules.d/60-nvme-scheduler.rules" "NVMe scheduler rules"
restore_file "set-cpu-governor.service.backup" "/etc/systemd/system/set-cpu-governor.service" "CPU governor systemd service"
restore_file "nvme-readahead.service.backup" "/etc/systemd/system/nvme-readahead.service" "NVMe readahead systemd service"

restore_file "bashrc.backup" "$HOME/.bashrc" "BASHRC"

if [[ -f "$BACKUP_DIR/gnome_settings.backup" ]]; then
    read -p "Restore GNOME settings? (y/n): " restore_gnome
    if [[ $restore_gnome == "y" ]]; then
        dconf load /org/gnome/ < "$BACKUP_DIR/gnome_settings.backup"
        echo "✅ GNOME settings restored."
    else
        echo "Skipping GNOME settings restore."
    fi
fi

echo "🔄 A system reboot is recommended to fully apply restored configurations."
EOF

    chmod +x "$backup_path/restore.sh"

    log_success "Backup completed in: $backup_path"
    log_info "To restore, run: bash $backup_path/restore.sh"
}

# --- Execution ---
echo "🚀 Running Backup Safety Script..."

create_backup

echo "✅ Backup process complete."
