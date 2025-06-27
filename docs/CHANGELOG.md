# Changelog - Pop-OS Optimizer

## 🚀 Version 2.0.0 - Refactored Development Edition

### ✨ New Features & Improvements
- **Full English Translation**: All scripts, documentation, and user-facing text have been translated from Italian to English.
- **Centralized Configuration (`config.sh`)**: Introduced a single `config.sh` file for all customizable settings, allowing users to easily tailor optimizations without modifying core scripts.
- **Modular Script Architecture**: Individual optimization tasks are now separated into dedicated, well-defined scripts (`optimize_cpu.sh`, `optimize_memory.sh`, etc.) for better maintainability and clarity.
- **Improved Main Script (`pop-os-optimizer.sh`)**: Consolidated functionality from `PopOsOptimizer.sh`, `master_dev_optimization.sh`, and `master_optimization.sh` into a single, robust, and user-friendly main script.
- **Enhanced Backup & Restore**: The backup system (`backup_safety.sh`) now creates more comprehensive backups and generates an interactive `restore.sh` script within each backup folder for selective rollback.
- **Safer GRUB Configuration**: GRUB modifications (`optimize_boot.sh`) now use `sed` for targeted changes, preserving existing settings and improving safety.
- **Generic System Information**: System statistics and tests are now more generic, reducing reliance on specific hardware models.
- **Improved Logging**: All scripts now use consistent logging functions for better traceability.
- **Updated Documentation**: `README.md` has been completely rewritten to reflect the new structure, usage, and customization options.

### 🗑️ Removed
- `ISTRUZIONI.md` (content merged into `README.md`)
- `dev_cpu_boost.sh` (replaced by `optimize_cpu.sh`)
- `dev_memory_optimization.sh` (replaced by `optimize_memory.sh`)
- `dev_ssd_optimization.sh` (replaced by `optimize_ssd.sh`)
- `dev_grub_advanced.sh` (replaced by `optimize_boot.sh`)
- `dev_desktop_advanced.sh` (replaced by `optimize_desktop.sh`)
- `services_optimization.sh` (replaced by `optimize_services.sh`)
- `dev_software_stack.sh` (replaced by `install_software_stack.sh`)
- `dev_monitoring.sh` (merged into `setup_monitoring.sh`)
- `dev_monitoring_compact.sh` (merged into `setup_monitoring.sh`)
- `master_dev_optimization.sh` (merged into `pop-os-optimizer.sh`)
- `master_optimization.sh` (merged into `pop-os-optimizer.sh`)
- `PopOsOptimizer.sh` (renamed to `pop-os-optimizer.sh`)

## 🚀 Version 1.0.0 - Development Edition (Initial Release)

### ✨ Features
- CPU Boost Enabler for AMD Ryzen
- Memory optimizations for 32GB RAM
- NVMe SSD optimizations (I/O scheduler, TRIM)
- GRUB and kernel parameter tuning for faster boot
- Desktop environment optimizations for development workflow
- Installation of common development tools and languages
- Basic system monitoring setup
- Automatic backup and restore functionality

### 🎯 Specific Optimizations
- Tailored for AMD Ryzen 7 5800X, RTX 3080, 32GB RAM, NVMe SSD, Pop!_OS 22.04

### 📊 Performance Improvements
- Boot Time: ~40% reduction
- CPU Performance: ~40% increase (with boost enabled)
- Compilation Speed: ~35% increase
- Desktop Responsiveness: ~50% increase

### 🛡️ Security
- Automatic configuration backups
- Restore scripts for rollback
- Pre-execution checks and detailed logging