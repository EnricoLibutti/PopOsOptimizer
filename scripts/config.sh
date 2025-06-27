#!/bin/bash
# -----------------------------------------------------------------------------
# Pop-OS Optimizer Configuration File
# -----------------------------------------------------------------------------
# This file contains all the settings used by the optimizer scripts.
#
# Instructions:
# 1. Review the default settings below.
# 2. Change values to "true" or "false" to enable or disable features.
# 3. Adjust values like swappiness or package lists to your needs.
# 4. Save the file before running the main optimizer script.
#
# Legend:
# - A value of "true" enables the optimization.
# - A value of "false" disables it.
# - Text values should be enclosed in "quotes".
# - Lists of packages are space-separated and enclosed in "quotes".
# -----------------------------------------------------------------------------

# --- ⚙️ General Settings ---

# The directory where backups will be stored.
# Default: "../backups" (relative to the main script)
BACKUP_DIR="backups"

# Enable hardware validation before applying optimizations
# This will check if the hardware supports the requested optimizations
ENABLE_HARDWARE_VALIDATION=true

# Skip optimizations that fail validation instead of aborting
SKIP_FAILED_VALIDATIONS=true


# --- 🔥 CPU Optimization (optimize_cpu.sh) ---

# Enable/disable CPU Boost. For AMD, this is critical for performance.
# Recommended: true
ENABLE_CPU_BOOST=true

# Set the CPU governor.
# "performance": Locks CPU at max frequency. Best for performance, uses more power.
# "schedutil": A modern, balanced kernel governor. Good for most use cases.
# "ondemand": A classic, balanced governor.
# Recommended: "performance" for desktops, "schedutil" for laptops.
CPU_GOVERNOR="performance"


# --- 💾 Memory Optimization (optimize_memory.sh) ---

# Set kernel `sysctl` parameters for memory management.
# These are optimized for a 32GB RAM development machine.
# Review these carefully if you have less RAM.
MEMORY_SYSCTL_SETTINGS=(
    "vm.swappiness=10"                    # Strongly prefer RAM over swap
    "vm.vfs_cache_pressure=50"            # Reduce pressure to reclaim fs cache
    "vm.dirty_ratio=20"                   # Max % of memory for dirty pages
    "vm.dirty_background_ratio=10"        # % of memory to start background writes
    "vm.page-cluster=0"                   # Reduces I/O latency for SSDs
    "vm.overcommit_memory=1"              # Better for development tools (Docker, etc.)
    "kernel.sched_min_granularity_ns=10000000"
    "kernel.sched_wakeup_granularity_ns=15000000"
    "net.core.rmem_max=16777216"
    "net.core.wmem_max=16777216"
)


# --- 💿 SSD Optimization (optimize_ssd.sh) ---

# Enable the fstrim.timer for automatic weekly TRIM on SSDs.
# Recommended: true
ENABLE_AUTOMATIC_TRIM=true

# Set the I/O scheduler for NVMe drives.
# "mq-deadline": Good all-around scheduler for NVMe.
# "none": A simple, low-overhead scheduler.
# Recommended: "mq-deadline"
NVME_IO_SCHEDULER="mq-deadline"

# Set the read-ahead value in KB for the primary NVMe device.
# A lower value can reduce latency for random reads (common in development).
# Default: 4096 (2MB)
NVME_READ_AHEAD_KB=4096

# Kernel parameters for file watching (used by tools like Webpack, VSCode).
# Increase these if you work in very large projects.
FS_SYSCTL_SETTINGS=(
    "fs.file-max=100000"
    "fs.inotify.max_user_watches=524288"
    "fs.inotify.max_user_instances=512"
    "fs.inotify.max_queued_events=32768"
)


# --- 🚀 Boot Optimization (optimize_boot.sh) ---

# GRUB bootloader timeout in seconds.
# Recommended: 3
GRUB_TIMEOUT=3

# Advanced kernel boot parameters.
# WARNING: Modifying these can prevent your system from booting.
# These are heavily optimized for a specific AMD Ryzen system.
# Review and remove parameters if you have different hardware (e.g., Intel).
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amd_pstate=active mitigations=off nowatchdog nmi_watchdog=0"


# --- 🖥️ Desktop Optimization (optimize_desktop.sh) ---

# Disable desktop animations for a faster, more responsive feel.
# Recommended: true
DISABLE_DESKTOP_ANIMATIONS=true

# Set the number of static workspaces.
# Recommended: 6
NUM_WORKSPACES=6

# Set the monospace font for terminals and editors.
# Ensure the font is installed on your system.
# Recommended: "Fira Code Medium 11"
MONOSPACE_FONT="Fira Code Medium 11"

# Disable the GNOME file indexing and tracking services (Tracker).
# This can save resources if you don't use GNOME's file search features.
# Recommended: true
DISABLE_TRACKER_SERVICES=true


# --- ⚙️ Service Optimization (optimize_services.sh) ---

# List of systemd services to disable.
# Disabling services can reduce boot time and memory usage.
# Review this list carefully. Do not disable services you need.
SERVICES_TO_DISABLE=(
    "cups-browsed.service"  # Disables network printer discovery
    "avahi-daemon.service"  # Disables mDNS/DNS-SD discovery (zeroconf)
)


# --- 📦 Software Stack (install_software_stack.sh) ---

# A list of essential development packages to install.
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

# A list of common applications/packages to remove to free up space.
PACKAGES_TO_REMOVE=(
    "rhythmbox"
    "cheese"
    "gnome-todo"
    "geary"
)
