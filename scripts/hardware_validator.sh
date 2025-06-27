#!/bin/bash
# -----------------------------------------------------------------------------
# Hardware Validator
# -----------------------------------------------------------------------------
# This script validates hardware compatibility before applying optimizations
# -----------------------------------------------------------------------------

source "$(dirname "$0")/config.sh"

# --- Helper Functions ---
log_info() {
    echo "[VALIDATOR] $1"
}

log_success() {
    echo "[VALIDATOR SUCCESS] $1"
}

log_warning() {
    echo "[VALIDATOR WARNING] $1"
}

log_error() {
    echo "[VALIDATOR ERROR] $1"
}

# --- Validation Functions ---

validate_cpu_features() {
    log_info "Validating CPU features..."
    
    # Check if CPU boost is available
    if [[ ! -f "/sys/devices/system/cpu/cpufreq/boost" ]]; then
        log_warning "CPU boost not available on this system"
        export CPU_BOOST_AVAILABLE=false
    else
        export CPU_BOOST_AVAILABLE=true
        log_success "CPU boost available"
    fi
    
    # Check available governors
    if [[ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors" ]]; then
        local available_governors
        available_governors=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null || echo "")
        export AVAILABLE_GOVERNORS="$available_governors"
        log_info "Available CPU governors: $available_governors"
        
        if [[ "$available_governors" =~ $CPU_GOVERNOR ]]; then
            export CPU_GOVERNOR_AVAILABLE=true
            log_success "Requested governor '$CPU_GOVERNOR' is available"
        else
            export CPU_GOVERNOR_AVAILABLE=false
            log_warning "Requested governor '$CPU_GOVERNOR' not available"
        fi
    else
        export CPU_GOVERNOR_AVAILABLE=false
        log_warning "CPU frequency scaling not available"
    fi
}

validate_storage() {
    log_info "Validating storage devices..."
    
    # Check for NVMe devices
    local nvme_devices
    nvme_devices=$(lsblk -d -o NAME,ROTA | grep 'nvme' | wc -l)
    
    if [[ $nvme_devices -gt 0 ]]; then
        export NVME_AVAILABLE=true
        log_success "Found $nvme_devices NVMe device(s)"
        
        # Get primary NVMe device
        local primary_nvme
        primary_nvme=$(lsblk -d -o NAME,ROTA | grep 'nvme' | head -n 1 | awk '{print $1}')
        export PRIMARY_NVME_DEVICE="$primary_nvme"
        log_info "Primary NVMe device: /dev/$primary_nvme"
    else
        export NVME_AVAILABLE=false
        log_warning "No NVMe devices found"
    fi
    
    # Check if fstrim is available
    if command -v fstrim &> /dev/null; then
        export FSTRIM_AVAILABLE=true
        log_success "fstrim utility available"
    else
        export FSTRIM_AVAILABLE=false
        log_warning "fstrim utility not available"
    fi
}

validate_desktop_environment() {
    log_info "Validating desktop environment..."
    
    # Check if GNOME is running
    if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] || [[ "$XDG_CURRENT_DESKTOP" == *"Unity"* ]]; then
        export GNOME_AVAILABLE=true
        log_success "GNOME desktop environment detected"
        
        # Check if gsettings is available
        if command -v gsettings &> /dev/null; then
            export GSETTINGS_AVAILABLE=true
            log_success "gsettings utility available"
        else
            export GSETTINGS_AVAILABLE=false
            log_warning "gsettings utility not available"
        fi
    else
        export GNOME_AVAILABLE=false
        log_warning "GNOME desktop environment not detected (current: $XDG_CURRENT_DESKTOP)"
    fi
}

validate_system_services() {
    log_info "Validating system services..."
    
    # Check if systemctl is available
    if command -v systemctl &> /dev/null; then
        export SYSTEMCTL_AVAILABLE=true
        log_success "systemctl available"
    else
        export SYSTEMCTL_AVAILABLE=false
        log_error "systemctl not available - cannot manage services"
        return 1
    fi
    
    return 0
}

# --- Main Validation ---
run_hardware_validation() {
    log_info "Starting hardware validation..."
    
    validate_cpu_features
    validate_storage
    validate_desktop_environment
    validate_system_services
    
    log_info "Hardware validation completed"
    
    # Generate compatibility report
    cat << EOF

=== HARDWARE COMPATIBILITY REPORT ===
CPU Boost Available: ${CPU_BOOST_AVAILABLE:-false}
CPU Governor Available: ${CPU_GOVERNOR_AVAILABLE:-false}
Available Governors: ${AVAILABLE_GOVERNORS:-none}
NVMe Storage Available: ${NVME_AVAILABLE:-false}
Primary NVMe Device: ${PRIMARY_NVME_DEVICE:-none}
FSTRIM Available: ${FSTRIM_AVAILABLE:-false}
GNOME Desktop: ${GNOME_AVAILABLE:-false}
GSETTings Available: ${GSETTINGS_AVAILABLE:-false}
SystemCTL Available: ${SYSTEMCTL_AVAILABLE:-false}

EOF
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_hardware_validation
fi 