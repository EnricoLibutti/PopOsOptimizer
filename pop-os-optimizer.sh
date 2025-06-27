#!/bin/bash
# -----------------------------------------------------------------------------
# Pop-OS Optimizer - Main Script
# -----------------------------------------------------------------------------
# This is the main entry point for the Pop-OS Optimizer suite.
# It provides an interactive menu to apply various system optimizations
# based on the settings defined in `config.sh`.
#
# What it does:
# - Loads configuration from `config.sh`.
# - Provides a user-friendly menu for selecting optimizations.
# - Executes individual optimization scripts.
# - Offers a "Complete Optimization" option to run all recommended optimizations.
# - Includes system information display and basic system tests.
# -----------------------------------------------------------------------------

set -e

# --- Configuration and Paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
BACKUPS_DIR="$SCRIPT_DIR/backups"
LOG_FILE="$SCRIPT_DIR/optimizer.log"

# Load configuration
source "$SCRIPTS_DIR/config.sh"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# --- Helper Functions ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                      🚀 Pop-OS Optimizer - Development Edition                      ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE} 🖥️  Optimized for Development Workstations                                         ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🐧 Pop!_OS 22.04 LTS    ${CYAN}│${WHITE} 🔧 Customizable ${CYAN}│${WHITE} ⚡ Performance Focused ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_system_info() {
    echo -e "${BLUE}📊 CURRENT SYSTEM STATUS:${NC}"
    echo -e "   ${WHITE}🔥 CPU Boost:${NC} $(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo -e "${RED}❌ Not Available${NC}")"
    echo -e "   ${WHITE}⚡ Governor:${NC} $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo -e "${RED}❌ Not Available${NC}")"
    echo -e "   ${WHITE}🚀 Boot Time:${NC} $(systemd-analyze | head -1 | awk '{print $4}')"
    echo -e "   ${WHITE}💾 Memory:${NC} $(free -h | grep Mem | awk '{print $3 "/" $2}')"
    echo -e "   ${WHITE}💿 Storage:${NC} $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}')"
    echo
}

show_main_menu() {
    echo -e "${YELLOW}🎯 MAIN MENU:${NC}"
    echo
    echo -e "${WHITE}  [1]${NC} 🔥 ${GREEN}Optimize CPU${NC}              ${BLUE}(Boost, Governor, etc.)${NC}"
    echo -e "${WHITE}  [2]${NC} 💾 ${GREEN}Optimize Memory${NC}           ${BLUE}(Swappiness, Caching, etc.)${NC}"
    echo -e "${WHITE}  [3]${NC} 💿 ${GREEN}Optimize SSD${NC}              ${BLUE}(TRIM, I/O Scheduler, etc.)${NC}"
    echo -e "${WHITE}  [4]${NC} 🚀 ${GREEN}Optimize Boot Time${NC}        ${BLUE}(GRUB, Kernel Parameters)${NC}"
    echo -e "${WHITE}  [5]${NC} 🖥️  ${GREEN}Optimize Desktop${NC}          ${BLUE}(Animations, Workspaces, Fonts)${NC}"
    echo -e "${WHITE}  [6]${NC} ⚙️  ${GREEN}Optimize Services${NC}         ${BLUE}(Disable Unnecessary Services)${NC}"
    echo -e "${WHITE}  [7]${NC} 📦 ${GREEN}Install Dev Software Stack${NC}  ${BLUE}(Languages, Tools, Docker)${NC}"
    echo -e "${WHITE}  [8]${NC} 📊 ${GREEN}Setup Monitoring Tools${NC}    ${BLUE}(Dashboard, btop, etc.)${NC}"
    echo
    echo -e "${YELLOW}🛡️  MANAGEMENT:${NC}"
    echo -e "${WHITE}  [9]${NC} 📁 ${GREEN}Create Full Backup${NC}        ${BLUE}(Backup of Critical Configurations)${NC}"
    echo -e "${WHITE} [10]${NC} 🔄 ${GREEN}Restore from Backup${NC}       ${BLUE}(Restore Previous Configurations)${NC}"
    echo
    echo -e "${YELLOW}🚀 AUTOMATION:${NC}"
    echo -e "${WHITE} [99]${NC} ⚡ ${GREEN}COMPLETE OPTIMIZATION${NC}     ${BLUE}(Runs All Recommended Optimizations)${NC}"
    echo
    echo -e "${YELLOW}📚 INFO & TOOLS:${NC}"
    echo -e "${WHITE} [11]${NC} 📊 ${GREEN}Show System Statistics${NC}    ${BLUE}(Performance and System Info)${NC}"
    echo -e "${WHITE} [12]${NC} 📖 ${GREEN}View Documentation${NC}        ${BLUE}(README and Changelog)${NC}"
    echo -e "${WHITE} [13]${NC} 🔍 ${GREEN}Run System Tests${NC}          ${BLUE}(Benchmarks and Verifications)${NC}"
    echo
    echo -e "${WHITE}  [0]${NC} 👋 ${RED}Exit${NC}"
    echo
}

execute_script() {
    local script_name="$1"
    local description="$2"
    
    if [[ ! -f "$SCRIPTS_DIR/$script_name" ]]; then
        echo -e "${RED}❌ Script $script_name not found!${NC}"
        log "ERROR: Script $script_name not found."
        return 1
    fi
    
    echo -e "${CYAN}🔄 Executing: $description${NC}"
    log "Executing: $script_name - $description"
    
    if bash "$SCRIPTS_DIR/$script_name"; then
        echo -e "${GREEN}✅ $description completed!${NC}"
        log "SUCCESS: $script_name completed."
    else
        echo -e "${RED}❌ Error during: $description${NC}"
        log "ERROR: $script_name failed."
        return 1
    fi
}

show_statistics() {
    clear
    print_header
    echo -e "${YELLOW}📊 SYSTEM STATISTICS:${NC}"
    echo
    
    echo -e "${BLUE}🔥 CPU PERFORMANCE:${NC}"
    echo -e "   Model: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')"
    echo -e "   Cores: $(nproc)"
    echo -e "   Current Freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null | awk '{print $1/1000}' || echo 'N/A') MHz"
    echo -e "   Max Freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null | awk '{print $1/1000}' || echo 'N/A') MHz"
    echo -e "   Boost: $(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo 'N/A')"
    echo -e "   Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'N/A')"
    echo
    
    echo -e "${BLUE}💾 MEMORY:${NC}"
    free -h | grep -E "(Mem|Swap)" | while read line; do
        echo -e "   $line"
    done
    echo
    
    echo -e "${BLUE}💿 STORAGE:${NC}"
df -h / /home 2>/dev/null | tail -n +2 | while read line; do
        echo -e "   $line"
    done
    echo
    
    if command -v nvidia-smi &>/dev/null; then
        echo -e "${BLUE}🎮 GPU:${NC}"
        echo -e "   Model: $(nvidia-smi --query-gpu=name --format=csv,noheader,nounits)"
        echo -e "   Temperature: $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)°C"
        echo -e "   Utilization: $(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)%"
        echo -e "   Memory: $(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)MB / $(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)MB"
        echo
    fi
    
    echo -e "${BLUE}🚀 BOOT PERFORMANCE:${NC}"
    systemd-analyze | head -1
    echo
    
    echo -e "${BLUE}⚡ TOP PROCESSES (by CPU):${NC}"
    ps aux --sort=-%cpu | head -6 | awk 'NR==1{print "   " $0} NR>1{printf "   %-20s %s%% CPU %s%% MEM\\n", $11, $3, $4}'
    echo
}

run_system_test() {
    clear
    print_header
    echo -e "${YELLOW}🔍 SYSTEM TESTS:${NC}"
    echo
    
    echo -e "${BLUE}🔥 CPU Boost Test:${NC}"
    boost_status=$(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo "0")
    if [[ "$boost_status" == "1" ]]; then
        echo -e "   ${GREEN}✅ CPU Boost ENABLED${NC}"
    else
        echo -e "   ${RED}❌ CPU Boost DISABLED (Critical for development!)${NC}"
    fi
    
    echo -e "${BLUE}⚡ Governor Test:${NC}"
    governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    if [[ "$governor" == "performance" ]]; then
        echo -e "   ${GREEN}✅ Performance Governor ACTIVE${NC}"
    else
        echo -e "${YELLOW}⚠️  Governor: $governor (Recommended: performance)${NC}"
    fi
    
    echo -e "${BLUE}💾 Memory Test:${NC}"
    swap_usage=$(free | grep Swap | awk '{if($2>0) print ($3/$2)*100; else print 0}')
    if (( $(echo "$swap_usage < 10" | bc -l) )); then
        echo -e "   ${GREEN}✅ Swap Usage: ${swap_usage}% (Optimal for development with sufficient RAM)${NC}"
    else
        echo -e "${YELLOW}⚠️  Swap Usage: ${swap_usage}% (Could be optimized)${NC}"
    fi
    
    echo -e "${BLUE}💿 SSD TRIM Test:${NC}"
    if systemctl is-enabled fstrim.timer &>/dev/null; then
        echo -e "   ${GREEN}✅ Automatic TRIM ENABLED${NC}"
    else
        echo -e "${YELLOW}⚠️  Automatic TRIM not configured${NC}"
    fi
    
    echo -e "${BLUE}🖥️  Desktop Animations Test:${NC}"
    animations=$(gsettings get org.gnome.desktop.interface enable-animations 2>/dev/null || echo "true")
    if [[ "$animations" == "false" ]]; then
        echo -e "   ${GREEN}✅ Animations DISABLED (Optimal for development)${NC}"
    else
        echo -e "${YELLOW}⚠️  Animations ENABLED (May impact performance)${NC}"
    fi
    
    echo
}

complete_optimization() {
    clear
    print_header
    echo -e "${YELLOW}⚡ COMPLETE OPTIMIZATION${NC}"
    echo
    echo -e "${CYAN}This operation will execute ALL recommended optimizations:${NC}"
    echo -e "   🔥 Optimize CPU"
    echo -e "   💾 Optimize Memory"
    echo -e "   💿 Optimize SSD"
    echo -e "   🚀 Optimize Boot Time"
    echo -e "   🖥️ Optimize Desktop"
    echo -e "   ⚙️ Optimize Services"
    echo -e "   📊 Setup Monitoring Tools"
    echo
    echo -e "${RED}⚠️  WARNING: A system reboot will be required!${NC}"
    echo
    read -p "🚀 Proceed with complete optimization? (y/n): " confirm
    
    if [[ $confirm != "y" ]]; then
        echo -e "${YELLOW}👋 Operation cancelled.${NC}"
        return 0
    fi
    
    # Automatic backup
    echo -e "${CYAN}📁 Creating automatic backup...${NC}"
    execute_script "backup_safety.sh" "Security Backup"
    
    # Optimizations
    execute_script "optimize_cpu.sh" "CPU Optimization"
    execute_script "optimize_memory.sh" "Memory Optimization"
    execute_script "optimize_ssd.sh" "SSD Optimization"
    execute_script "optimize_boot.sh" "Boot Time Optimization"
    execute_script "optimize_desktop.sh" "Desktop Optimization"
    execute_script "optimize_services.sh" "Services Optimization"
    execute_script "setup_monitoring.sh" "Monitoring Tools Setup"
    
    echo
    echo -e "${GREEN}🎉 COMPLETE OPTIMIZATION FINISHED!${NC}"
    echo
    echo -e "${CYAN}📊 EXPECTED RESULTS:${NC}"
    echo -e "   🚀 Boot Time: Significantly reduced"
    echo -e "   🔥 CPU Performance: Improved (boost enabled)"
    echo -e "   💾 Memory Efficiency: Optimized for your RAM configuration"
    echo -e "   💿 SSD Performance: Improved (scheduler + TRIM)"
    echo -e "   🖥️ Desktop Responsiveness: Increased"
    echo
    echo -e "${YELLOW}📱 USEFUL COMMANDS (after reboot):${NC}"
    echo -e "   devmon     - Development monitoring dashboard"
    echo -e "   btop       - Advanced system monitor"
    echo -e "   nvidia-smi - GPU monitor (if NVIDIA GPU)"
    echo -e "   cpumon     - CPU frequency monitor"
    echo
    read -p "🔄 Reboot now to apply all optimizations? (y/n): " reboot_confirm
    if [[ $reboot_confirm == "y" ]]; then
        echo -e "${CYAN}🔄 Rebooting in 5 seconds...${NC}"
        sleep 5
        sudo reboot
    else
        echo -e "${YELLOW}⏰ Remember to reboot with: sudo reboot${NC}"
    fi
}

# Main loop
main() {
    # Create directories if they don't exist
    mkdir -p "$BACKUPS_DIR" "$SCRIPTS_DIR"
    
    # Verify permissions
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ Do NOT run this script as root!${NC}"
        exit 1
    fi
    
    while true; do
        print_header
        print_system_info
        show_main_menu
        
        read -p "🎯 Choose an option: " choice
        echo
        
        case $choice in
            1) execute_script "optimize_cpu.sh" "CPU Optimization" ;;
            2) execute_script "optimize_memory.sh" "Memory Optimization" ;;
            3) execute_script "optimize_ssd.sh" "SSD Optimization" ;;
            4) execute_script "optimize_boot.sh" "Boot Time Optimization" ;;
            5) execute_script "optimize_desktop.sh" "Desktop Optimization" ;;
            6) execute_script "optimize_services.sh" "Services Optimization" ;;
            7) execute_script "install_software_stack.sh" "Development Software Stack Installation" ;;
            8) execute_script "setup_monitoring.sh" "Monitoring Tools Setup" ;;
            9) execute_script "backup_safety.sh" "Full Backup" ;;
            10) 
                if [[ -d "$BACKUPS_DIR" ]] && [[ -n "$(ls -A $BACKUPS_DIR 2>/dev/null)" ]]; then
                    echo -e "${CYAN}📁 Available Backups:${NC}"
                    ls -la "$BACKUPS_DIR"
                    echo
                    read -p "Enter the name of the backup to restore: " backup_name
                    if [[ -f "$BACKUPS_DIR/$backup_name/restore.sh" ]]; then
                        bash "$BACKUPS_DIR/$backup_name/restore.sh"
                    else
                        echo -e "${RED}❌ Restore script not found for $backup_name!${NC}"
                    fi
                else
                    echo -e "${YELLOW}⚠️  No backups found!${NC}"
                fi
                ;;
            11) show_statistics ;;
            12) 
                if [[ -f "$SCRIPT_DIR/README.md" ]]; then
                    less "$SCRIPT_DIR/README.md"
                else
                    echo -e "${RED}❌ README.md not found!${NC}"
                fi
                ;;
            13) run_system_test ;;
            99) complete_optimization ;;
            0) 
                echo -e "${GREEN}👋 Thank you for using Pop-OS Optimizer!${NC}"
                echo -e "${CYAN}🚀 For support: https://github.com/popOS-optimizer (Placeholder)${NC}"
                exit 0 
                ;;
            *) 
                echo -e "${RED}❌ Invalid option!${NC}"
                ;;
        esac
        
        echo
        read -p "📱 Press ENTER to continue..."
    done
}

# Start the program
main "$@"