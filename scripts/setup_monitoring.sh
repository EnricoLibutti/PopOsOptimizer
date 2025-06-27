#!/bin/bash
# -----------------------------------------------------------------------------
# Monitoring Setup
# -----------------------------------------------------------------------------
# This script sets up system monitoring tools and custom aliases.
#
# What it does:
# - Installs essential monitoring utilities (htop, btop, iotop, etc.).
# - Creates a custom `devmon` script for a quick overview of system status.
# - Adds useful monitoring aliases to ~/.bashrc.
# -----------------------------------------------------------------------------

set -e

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

# Installs monitoring tools
install_monitoring_tools() {
    log_info "Installing monitoring tools..."
    sudo apt install -y htop btop iotop nethogs ncdu glances lm-sensors stress-ng sysbench
    log_success "Monitoring tools installed."
}

# Creates the custom devmon script
create_devmon_script() {
    log_info "Creating custom 'devmon' script..."
    local devmon_script_path="$HOME/devmon.sh"
    cat > "$devmon_script_path" << 'EOF'
#!/bin/bash
clear
echo "DEVELOPMENT WORKSTATION MONITOR - $(date)"
echo "================================================================"

echo "SYSTEM: $(hostname) | $(uptime -p) | Load: $(uptime | awk -F'load average:' '{print $2}')"

echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//' | cut -c1-30)..."
echo "   Cores: $(nproc) | Freq: $(cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}') MHz"
echo "   Boost: $(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo 'N/A') | Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'N/A')"

echo "MEMORY:"
free -h | grep -E "(Mem|Swap)"

echo "STORAGE:"
df -h / /home 2>/dev/null | tail -n +2

if nvidia-smi &>/dev/null; then
    echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader,nounits)"
    echo "   Temp: $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)°C | Usage: $(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)%"
fi

echo "TOP DEVELOPMENT PROCESSES:"
ps aux --sort=-%cpu | grep -E "(code|cursor|firefox|node|npm|docker|python|java)" | head -5 | awk '{printf "   %-20s %s%% CPU %s%% MEM\n", $11, $3, $4}'

echo "================================================================"
echo "Commands: btop | nvidia-smi | iotop | nethogs"
EOF

    chmod +x "$devmon_script_path"
    log_success "'devmon.sh' script created at $devmon_script_path."
}

# Adds monitoring aliases to ~/.bashrc
add_monitoring_aliases() {
    log_info "Adding monitoring aliases to ~/.bashrc..."
    local aliases_block="
# --- Monitoring Aliases ---
alias devmon='$HOME/devmon.sh'
alias cpumon='watch -n 1 "grep MHz /proc/cpuinfo"'
alias gpumon='watch -n 1 nvidia-smi'
alias diskmon='watch -n 1 \"df -h | grep -E (/$|/home)\"'
# --- End Monitoring Aliases ---
"

    if ! grep -q "# --- Monitoring Aliases ---" ~/.bashrc; then
        echo "$aliases_block" >> ~/.bashrc
        log_success "Monitoring aliases added to ~/.bashrc."
        log_warning "Please restart your terminal or run 'source ~/.bashrc' to apply aliases."
    else
        log_info "Monitoring aliases already exist in ~/.bashrc. Skipping."
    fi
}

# --- Execution ---
echo "🚀 Running Monitoring Setup..."

install_monitoring_tools
create_devmon_script
add_monitoring_aliases

echo "✅ Monitoring setup complete."
