# Pop-OS Optimizer - Development Edition

## Overview

This is a comprehensive optimization suite designed to enhance the performance and responsiveness of Pop!_OS, particularly for development workstations. It provides a modular and customizable approach to system tuning, allowing users to select specific optimizations or apply a complete set of recommended settings.

## Features

*   **CPU Optimization:** Fine-tunes CPU performance, including CPU boost and governor settings.
*   **Memory Optimization:** Optimizes RAM usage and caching for improved multitasking and application responsiveness.
*   **SSD Optimization:** Enhances NVMe SSD performance through TRIM, I/O scheduler adjustments, and file system tuning.
*   **Boot Time Optimization:** Reduces system boot time by optimizing GRUB and kernel parameters.
*   **Desktop Optimization:** Improves desktop environment responsiveness by disabling animations and configuring workspace behavior.
*   **Service Optimization:** Disables unnecessary system services to free up resources.
*   **Software Stack Installation:** Installs essential development tools, languages, and runtimes (e.g., Docker, Python, Node.js).
*   **Monitoring Setup:** Configures system monitoring tools and provides a custom `devmon` script for quick system overview.
*   **Backup & Restore:** Creates comprehensive backups of critical system configurations and provides an easy way to restore them.

## Getting Started

1.  **Navigate to the project directory:**

    ```bash
    cd ~/Desktop/PopOsOptimizer
    ```

2.  **Make the main script executable:**

    ```bash
    chmod +x ./pop-os-optimizer.sh
    ```

3.  **Run the main optimizer script:**

    ```bash
    ./pop-os-optimizer.sh
    ```

    Alternatively, you can double-click `pop-os-optimizer.sh` in your file manager and choose "Run in Terminal."

## Customization

All optimization settings are managed through the `scripts/config.sh` file. Before running any optimizations, you can edit this file to:

*   Enable or disable specific features (e.g., `ENABLE_CPU_BOOST=true`).
*   Adjust values like `SWAPPINESS` or `GRUB_TIMEOUT`.
*   Customize lists of packages to install or remove.

**It is highly recommended to review `scripts/config.sh` to tailor the optimizations to your specific hardware and workflow.**

## Project Structure

```
PopOsOptimizer/
├── pop-os-optimizer.sh       # Main script (run this!)
├── optimizer.log             # Log of operations (automatically created)
├── README.md                 # This documentation file
├── backups/                  # Automatic backups are stored here
├── docs/
│   └── CHANGELOG.md          # List of changes and versions
└── scripts/
    ├── config.sh             # Customizable settings for all optimizations
    ├── backup_safety.sh      # Creates system backups
    ├── optimize_cpu.sh       # CPU optimization script
    ├── optimize_memory.sh    # Memory optimization script
    ├── optimize_ssd.sh       # SSD optimization script
    ├── optimize_boot.sh      # Boot time optimization script
    ├── optimize_desktop.sh   # Desktop environment optimization script
    ├── optimize_services.sh  # System services optimization script
    ├── install_software_stack.sh # Installs development software
    └── setup_monitoring.sh   # Sets up monitoring tools
```

## Important Notes

*   **Do NOT run this script as root.** The script will prompt for `sudo` when necessary.
*   **Backup is always created.** Before any major optimization, a backup of critical system files is automatically created in the `backups/` directory. You can also manually create a backup from the main menu.
*   **Reboot is often required.** Many optimizations, especially those related to GRUB or kernel parameters, require a system reboot to take full effect.

## Expected Results (after complete optimization and reboot)

*   **Boot Time:** Significantly reduced.
*   **CPU Performance:** Improved, especially with CPU boost enabled.
*   **Memory Efficiency:** Optimized for your system's RAM configuration.
*   **SSD Performance:** Enhanced responsiveness and longevity.
*   **Desktop Responsiveness:** A snappier and more fluid user experience.
*   **Compilation Speed:** Faster build times for development projects.

## Troubleshooting & Rollback

If you encounter any issues or wish to revert changes:

1.  **Restore from Backup:**
    *   Run `./pop-os-optimizer.sh` and select option `[10] Restore from Backup`.
    *   Choose the desired backup from the list.
    *   Follow the prompts to restore specific configurations.

2.  **Manual Rollback:**
    *   Navigate to the `backups/` directory.
    *   Enter the specific backup folder (e.g., `backups/optimization_backup_YYYYMMDD_HHMMSS`).
    *   Run the `restore.sh` script located inside that folder: `bash ./restore.sh`.

3.  **Check Logs:**
    *   Review `optimizer.log` in the main project directory for detailed information on executed operations and any errors.

## Support

For issues or contributions, please visit the GitHub repository: [https://github.com/popOS-optimizer](https://github.com/popOS-optimizer) (Placeholder - replace with actual link)

**Happy Developing! 🚀**