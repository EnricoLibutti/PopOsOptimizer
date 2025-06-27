#!/bin/bash
# -----------------------------------------------------------------------------
# CPU Optimizer
# -----------------------------------------------------------------------------
# This script optimizes CPU performance based on settings in config.sh.
#
# What it does:
# - Enables or disables CPU Boost.
# - Sets the CPU frequency governor for all cores.
# - Makes the governor setting persistent across reboots.
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

log_error() {
    echo "[ERROR] $1"
    exit 1
}

# --- Main Functions ---

# Enables or disables CPU boost
enable_cpu_boost() {
    if [[ ! -f "/sys/devices/system/cpu/cpufreq/boost" ]]; then
        log_warning "CPU boost setting not available on this system. Skipping."
        return
    fi

    local current_boost_status
    current_boost_status=$(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo "0")
    local target_boost_status=$([ "$ENABLE_CPU_BOOST" = true ] && echo 1 || echo 0)

    if [[ "$current_boost_status" == "$target_boost_status" ]]; then
        log_info "CPU Boost is already set to the desired state ('$ENABLE_CPU_BOOST')."
    else
        log_info "Setting CPU Boost to '$ENABLE_CPU_BOOST'..."
        
        # Check if the file is writable
        if [[ ! -w "/sys/devices/system/cpu/cpufreq/boost" ]]; then
            # Try with sudo
            if echo "$target_boost_status" | sudo tee /sys/devices/system/cpu/cpufreq/boost > /dev/null 2>&1; then
                log_success "CPU Boost has been set to '$ENABLE_CPU_BOOST'."
            else
                log_warning "Failed to set CPU Boost. This may not be supported on your CPU/kernel."
                return
            fi
        else
            echo "$target_boost_status" > /sys/devices/system/cpu/cpufreq/boost
            log_success "CPU Boost has been set to '$ENABLE_CPU_BOOST'."
        fi
    fi
}

# Sets the CPU governor for all cores
set_cpu_governor() {
    log_info "Setting CPU governor to '$CPU_GOVERNOR' for all cores..."

    # Check if the governor is available
    local available_governors=""
    if [[ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors" ]]; then
        available_governors=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null || echo "")
        if [[ ! "$available_governors" =~ $CPU_GOVERNOR ]]; then
            log_warning "Governor '$CPU_GOVERNOR' is not available. Available governors: $available_governors"
            log_warning "Falling back to 'schedutil' governor."
            CPU_GOVERNOR="schedutil"
            if [[ ! "$available_governors" =~ $CPU_GOVERNOR ]]; then
                log_warning "schedutil not available either. Using default governor."
                return
            fi
        fi
    fi

    local success_count=0
    local total_count=0
    
    for cpu_gov_file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [[ -f "$cpu_gov_file" ]]; then
            total_count=$((total_count + 1))
            local current_governor
            current_governor=$(cat "$cpu_gov_file" 2>/dev/null || echo "unknown")
            if [[ "$current_governor" != "$CPU_GOVERNOR" ]]; then
                if echo "$CPU_GOVERNOR" | sudo tee "$cpu_gov_file" > /dev/null 2>&1; then
                    success_count=$((success_count + 1))
                else
                    log_warning "Failed to set governor for $(basename "$(dirname "$cpu_gov_file")")"
                fi
            else
                success_count=$((success_count + 1))
            fi
        fi
    done

    if [[ $success_count -eq $total_count && $total_count -gt 0 ]]; then
        log_success "CPU governor set to '$CPU_GOVERNOR' for all $total_count cores."
    else
        log_warning "CPU governor set for $success_count out of $total_count cores."
    fi
}

# Makes the governor setting persistent
make_governor_persistent() {
    if ! command -v cpupower-gui &> /dev/null; then
        log_info "Installing 'cpupower-gui' to manage governor settings persistently..."
        sudo apt-get update > /dev/null
        sudo apt-get install -y cpupower-gui > /dev/null
    fi

    # Create a systemd service to set the governor on boot
    local service_content="[Unit]
Description=Set CPU Governor to $CPU_GOVERNOR

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower-gui -g $CPU_GOVERNOR

[Install]
WantedBy=multi-user.target"

    echo "$service_content" | sudo tee /etc/systemd/system/set-cpu-governor.service > /dev/null
    sudo systemctl daemon-reload
    sudo systemctl enable set-cpu-governor.service > /dev/null

    log_success "Governor '$CPU_GOVERNOR' will be applied on every boot."
}

# --- Execution ---
echo "🚀 Running CPU Optimizer..."

enable_cpu_boost
set_cpu_governor
make_governor_persistent

echo "✅ CPU optimization complete."
