#!/bin/bash
# -----------------------------------------------------------------------------
# Pop-OS Optimizer Configuration File - Enhanced with Presets
# -----------------------------------------------------------------------------
# This file contains all the settings used by the optimizer scripts.
#
# QUICK SETUP - Choose a preset:
# 1. Set PRESET to one of: "working", "gaming", "server", "conservative", "custom"
# 2. For custom preset, configure individual settings below
# 3. Save the file before running the main optimizer script.
# -----------------------------------------------------------------------------

# =============================================================================
# 🎯 PRESET SELECTION (Choose one)
# =============================================================================
# Available presets:
# - "working"      : Optimized for development and office work
# - "gaming"       : Optimized for gaming performance
# - "server"       : Optimized for server/headless environments  
# - "conservative" : Minimal optimizations for stability
# - "custom"       : Use individual settings below

PRESET="working"

# =============================================================================
# 📋 PRESET CONFIGURATIONS
# =============================================================================

apply_preset() {
    case "$PRESET" in
        "working")
            # Development and office work optimizations
            ENABLE_HARDWARE_VALIDATION=true
            SKIP_FAILED_VALIDATIONS=true
            ENABLE_CPU_BOOST=true
            CPU_GOVERNOR="performance"  # Performance for development work
            MEMORY_SYSCTL_SETTINGS=(
                "vm.swappiness=10"
                "vm.vfs_cache_pressure=50"
                "vm.dirty_ratio=15"
                "vm.dirty_background_ratio=5"
                "vm.page-cluster=0"
                "vm.overcommit_memory=1"
                "kernel.sched_min_granularity_ns=10000000"
                "kernel.sched_wakeup_granularity_ns=15000000"
                "net.core.rmem_max=16777216"
                "net.core.wmem_max=16777216"
            )
            ENABLE_AUTOMATIC_TRIM=true
            NVME_IO_SCHEDULER="mq-deadline"
            NVME_READ_AHEAD_KB=4096
            FS_SYSCTL_SETTINGS=(
                "fs.file-max=100000"
                "fs.inotify.max_user_watches=524288"
                "fs.inotify.max_user_instances=512"
                "fs.inotify.max_queued_events=32768"
            )
            GRUB_TIMEOUT=3
            GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mitigations=off"
            DISABLE_DESKTOP_ANIMATIONS=true
            NUM_WORKSPACES=6
            MONOSPACE_FONT="Fira Code Medium 11"
            DISABLE_TRACKER_SERVICES=true
            SERVICES_TO_DISABLE=(
                "cups-browsed.service"
                "avahi-daemon.service"
            )
            DEV_PACKAGES_TO_INSTALL=(
                "build-essential" "cmake" "ninja-build" "git" "vim" "neovim"
                "curl" "wget" "htop" "btop" "tree" "jq" "unzip"
                "python3-pip" "python3-venv" "nodejs" "npm"
                "docker.io" "docker-compose" "code" "firefox-dev"
            )
            PACKAGES_TO_REMOVE=(
                "rhythmbox" "cheese" "gnome-todo" "geary"
            )
            ;;
            
        "gaming")
            # Gaming performance optimizations
            ENABLE_HARDWARE_VALIDATION=true
            SKIP_FAILED_VALIDATIONS=false
            ENABLE_CPU_BOOST=true
            CPU_GOVERNOR="performance"  # Maximum performance
            MEMORY_SYSCTL_SETTINGS=(
                "vm.swappiness=1"         # Minimal swap usage
                "vm.vfs_cache_pressure=50"
                "vm.dirty_ratio=30"       # Higher dirty pages for gaming
                "vm.dirty_background_ratio=15"
                "vm.page-cluster=0"
                "vm.overcommit_memory=1"
                "kernel.sched_min_granularity_ns=5000000"    # Lower latency
                "kernel.sched_wakeup_granularity_ns=8000000"
                "net.core.rmem_max=33554432"  # Larger network buffers
                "net.core.wmem_max=33554432"
            )
            ENABLE_AUTOMATIC_TRIM=true
            NVME_IO_SCHEDULER="none"      # Minimal overhead for gaming
            NVME_READ_AHEAD_KB=2048       # Lower for random reads
            FS_SYSCTL_SETTINGS=(
                "fs.file-max=200000"
                "fs.inotify.max_user_watches=524288"
                "fs.inotify.max_user_instances=512"
                "fs.inotify.max_queued_events=32768"
            )
            GRUB_TIMEOUT=1
            GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mitigations=off nowatchdog nmi_watchdog=0 processor.max_cstate=1"
            DISABLE_DESKTOP_ANIMATIONS=true
            NUM_WORKSPACES=4
            MONOSPACE_FONT="Source Code Pro Medium 11"
            DISABLE_TRACKER_SERVICES=true
            SERVICES_TO_DISABLE=(
                "cups-browsed.service"
                "avahi-daemon.service"
                "bluetooth.service"
            )
            DEV_PACKAGES_TO_INSTALL=(
                "steam" "lutris" "gamemode" "mangohud"
                "build-essential" "git" "curl" "wget" "htop"
            )
            PACKAGES_TO_REMOVE=(
                "rhythmbox" "cheese" "gnome-todo" "geary" "libreoffice-common"
            )
            ;;
            
        "server")
            # Server/headless optimizations
            ENABLE_HARDWARE_VALIDATION=true
            SKIP_FAILED_VALIDATIONS=true
            ENABLE_CPU_BOOST=true
            CPU_GOVERNOR="ondemand"       # Balanced for servers
            MEMORY_SYSCTL_SETTINGS=(
                "vm.swappiness=5"         # Very minimal swap
                "vm.vfs_cache_pressure=50"
                "vm.dirty_ratio=40"       # Higher for server workloads
                "vm.dirty_background_ratio=20"
                "vm.page-cluster=3"       # Better for sequential I/O
                "vm.overcommit_memory=2"  # Conservative for servers
                "net.core.rmem_max=67108864"  # Large network buffers
                "net.core.wmem_max=67108864"
                "net.core.netdev_max_backlog=5000"
            )
            ENABLE_AUTOMATIC_TRIM=true
            NVME_IO_SCHEDULER="mq-deadline"
            NVME_READ_AHEAD_KB=8192       # Larger for server workloads
            FS_SYSCTL_SETTINGS=(
                "fs.file-max=500000"      # Higher for servers
                "fs.inotify.max_user_watches=1048576"
                "fs.inotify.max_user_instances=1024"
                "fs.inotify.max_queued_events=65536"
            )
            GRUB_TIMEOUT=5
            GRUB_CMDLINE_LINUX_DEFAULT="quiet"
            DISABLE_DESKTOP_ANIMATIONS=false  # No desktop in server mode
            NUM_WORKSPACES=1
            MONOSPACE_FONT=""
            DISABLE_TRACKER_SERVICES=true
            SERVICES_TO_DISABLE=(
                "cups-browsed.service"
                "avahi-daemon.service"
                "bluetooth.service"
                "gdm3.service"
            )
            DEV_PACKAGES_TO_INSTALL=(
                "build-essential" "git" "curl" "wget" "htop" "btop"
                "python3-pip" "nodejs" "docker.io" "docker-compose"
                "nginx" "ufw"
            )
            PACKAGES_TO_REMOVE=(
                "gnome-shell" "gdm3" "ubuntu-desktop"
            )
            ;;
            
        "conservative")
            # Minimal, safe optimizations
            ENABLE_HARDWARE_VALIDATION=true
            SKIP_FAILED_VALIDATIONS=true
            ENABLE_CPU_BOOST=false        # Conservative
            CPU_GOVERNOR="schedutil"      # Default modern governor
            MEMORY_SYSCTL_SETTINGS=(
                "vm.swappiness=60"        # Keep default
                "vm.vfs_cache_pressure=100" # Keep default
                "fs.inotify.max_user_watches=524288"  # Only essential
            )
            ENABLE_AUTOMATIC_TRIM=true
            NVME_IO_SCHEDULER="mq-deadline"
            NVME_READ_AHEAD_KB=4096
            FS_SYSCTL_SETTINGS=(
                "fs.inotify.max_user_watches=524288"
            )
            GRUB_TIMEOUT=5
            GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
            DISABLE_DESKTOP_ANIMATIONS=false
            NUM_WORKSPACES=4
            MONOSPACE_FONT=""
            DISABLE_TRACKER_SERVICES=false
            SERVICES_TO_DISABLE=()
            DEV_PACKAGES_TO_INSTALL=(
                "curl" "wget" "htop" "tree"
            )
            PACKAGES_TO_REMOVE=()
            ;;
            
        "custom")
            # Use individual settings below - no changes
            ;;
            
        *)
            echo "[ERROR] Unknown preset: $PRESET"
            echo "Available presets: working, gaming, server, conservative, custom"
            exit 1
            ;;
    esac
}

# Apply the selected preset
if [[ "$PRESET" != "custom" ]]; then
    apply_preset
fi

# =============================================================================
# ⚙️ INDIVIDUAL SETTINGS (Only used when PRESET="custom")
# =============================================================================

# Only modify these if PRESET="custom"
if [[ "$PRESET" == "custom" ]]; then

# --- General Settings ---
BACKUP_DIR="backups"
ENABLE_HARDWARE_VALIDATION=true
SKIP_FAILED_VALIDATIONS=true

# --- CPU Optimization ---
ENABLE_CPU_BOOST=true
CPU_GOVERNOR="performance"

# --- Memory Optimization ---
MEMORY_SYSCTL_SETTINGS=(
    "vm.swappiness=10"
    "vm.vfs_cache_pressure=50"
    "vm.dirty_ratio=20"
    "vm.dirty_background_ratio=10"
    "vm.page-cluster=0"
    "vm.overcommit_memory=1"
    "kernel.sched_min_granularity_ns=10000000"
    "kernel.sched_wakeup_granularity_ns=15000000"
    "net.core.rmem_max=16777216"
    "net.core.wmem_max=16777216"
)

# --- SSD Optimization ---
ENABLE_AUTOMATIC_TRIM=true
NVME_IO_SCHEDULER="mq-deadline"
NVME_READ_AHEAD_KB=4096
FS_SYSCTL_SETTINGS=(
    "fs.file-max=100000"
    "fs.inotify.max_user_watches=524288"
    "fs.inotify.max_user_instances=512"
    "fs.inotify.max_queued_events=32768"
)

# --- Boot Optimization ---
GRUB_TIMEOUT=3
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amd_pstate=active mitigations=off nowatchdog nmi_watchdog=0"

# --- Desktop Optimization ---
DISABLE_DESKTOP_ANIMATIONS=true
NUM_WORKSPACES=6
MONOSPACE_FONT="Fira Code Medium 11"
DISABLE_TRACKER_SERVICES=true

# --- Service Optimization ---
SERVICES_TO_DISABLE=(
    "cups-browsed.service"
    "avahi-daemon.service"
)

# --- Software Stack ---
DEV_PACKAGES_TO_INSTALL=(
    "build-essential"
    "cmake"
    "ninja-build"
    "git"
    "vim"
    "neovim"
    "curl"
    "wget"
    "htop"
    "btop"
    "tree"
    "jq"
    "unzip"
    "python3-pip"
    "python3-venv"
    "nodejs"
    "npm"
    "docker.io"
    "docker-compose"
)

PACKAGES_TO_REMOVE=(
    "rhythmbox"
    "cheese"
    "gnome-todo"
    "geary"
)

fi

# =============================================================================
# 📊 PRESET INFORMATION DISPLAY
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== POP-OS OPTIMIZER CONFIGURATION ==="
    echo "Selected Preset: $PRESET"
    echo ""
    case "$PRESET" in
        "working")
            echo "🖥️  WORKING PRESET"
            echo "   Optimized for development and office work"
            echo "   - Balanced CPU governor for efficiency"
            echo "   - Moderate memory settings"
            echo "   - Development tools included"
            echo "   - Desktop animations disabled"
            ;;
        "gaming")
            echo "🎮 GAMING PRESET"  
            echo "   Optimized for maximum gaming performance"
            echo "   - Performance CPU governor"
            echo "   - Aggressive memory settings"
            echo "   - Gaming tools included"
            echo "   - Minimal background services"
            ;;
        "server")
            echo "🖥️  SERVER PRESET"
            echo "   Optimized for server/headless environments"
            echo "   - Balanced CPU for server workloads"
            echo "   - Large network buffers"
            echo "   - Server tools included"
            echo "   - Desktop services disabled"
            ;;
        "conservative")
            echo "🛡️  CONSERVATIVE PRESET"
            echo "   Minimal, safe optimizations"
            echo "   - Safe CPU settings"
            echo "   - Minimal system changes"
            echo "   - Essential tools only"
            echo "   - Maximum compatibility"
            ;;
        "custom")
            echo "⚙️  CUSTOM PRESET"
            echo "   Using individual settings below"
            echo "   - Configure each option manually"
            echo "   - Full control over optimizations"
            ;;
    esac
    echo ""
fi
