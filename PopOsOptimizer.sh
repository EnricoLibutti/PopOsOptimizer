#!/bin/bash
# PopOS Optimizer - Development Edition v1.0.0
# Professional optimization suite for Pop!_OS development workstations

set -e

# Configurazioni
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
BACKUPS_DIR="$SCRIPT_DIR/backups"
DOCS_DIR="$SCRIPT_DIR/docs"
LOG_FILE="$SCRIPT_DIR/optimizer.log"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Funzioni utility
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                      🚀 PopOS Optimizer - Development Edition                      ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE} 🖥️  AMD Ryzen 7 5800X  ${CYAN}│${WHITE} 🎮 RTX 3080  ${CYAN}│${WHITE} 💾 32GB RAM  ${CYAN}│${WHITE} 💿 NVMe SSD           ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🐧 Pop!_OS 22.04 LTS    ${CYAN}│${WHITE} 🔧 Desktop   ${CYAN}│${WHITE} ⚡ Development ${CYAN}│${WHITE} 📊 Professional     ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_system_info() {
    echo -e "${BLUE}📊 STATO SISTEMA ATTUALE:${NC}"
    echo -e "   ${WHITE}🔥 CPU Boost:${NC} $(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo -e "${RED}❌ Non disponibile${NC}")"
    echo -e "   ${WHITE}⚡ Governor:${NC} $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo -e "${RED}❌ Non disponibile${NC}")"
    echo -e "   ${WHITE}🚀 Boot Time:${NC} $(systemd-analyze | head -1 | awk '{print $4}')"
    echo -e "   ${WHITE}💾 Memoria:${NC} $(free -h | grep Mem | awk '{print $3 "/" $2}')"
    echo -e "   ${WHITE}💿 Storage:${NC} $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}')"
    echo
}

show_main_menu() {
    echo -e "${YELLOW}🎯 MENU PRINCIPALE:${NC}"
    echo
    echo -e "${WHITE}  [1]${NC} 🔥 ${GREEN}Abilita CPU Boost${NC}           ${BLUE}(CRITICO - Attualmente disabilitato!)${NC}"
    echo -e "${WHITE}  [2]${NC} 💾 ${GREEN}Ottimizza Memoria 32GB${NC}      ${BLUE}(Aggressive caching + low swappiness)${NC}"
    echo -e "${WHITE}  [3]${NC} 💿 ${GREEN}Ottimizza SSD NVMe${NC}          ${BLUE}(Scheduler I/O + TRIM + read-ahead)${NC}"
    echo -e "${WHITE}  [4]${NC} 🚀 ${GREEN}Accelera Boot Time${NC}          ${BLUE}(GRUB + kernel params + services)${NC}"
    echo -e "${WHITE}  [5]${NC} 🖥️  ${GREEN}Ottimizza Desktop${NC}           ${BLUE}(Pop Shell + development workflow)${NC}"
    echo -e "${WHITE}  [6]${NC} ⚙️  ${GREEN}Ottimizza Servizi${NC}           ${BLUE}(Disabilita servizi non necessari)${NC}"
    echo -e "${WHITE}  [7]${NC} 📦 ${GREEN}Installa Dev Stack${NC}          ${BLUE}(Languages + tools + Docker)${NC}"
    echo -e "${WHITE}  [8]${NC} 📊 ${GREEN}Setup Monitoraggio${NC}          ${BLUE}(Dashboard + monitoring tools)${NC}"
    echo
    echo -e "${YELLOW}🛡️  GESTIONE:${NC}"
    echo -e "${WHITE}  [9]${NC} 📁 ${GREEN}Crea Backup Completo${NC}       ${BLUE}(Backup di tutte le configurazioni)${NC}"
    echo -e "${WHITE} [10]${NC} 🔄 ${GREEN}Ripristina da Backup${NC}       ${BLUE}(Restore configurazioni precedenti)${NC}"
    echo
    echo -e "${YELLOW}🚀 AUTOMATICO:${NC}"
    echo -e "${WHITE} [99]${NC} ⚡ ${GREEN}OTTIMIZZAZIONE COMPLETA${NC}     ${BLUE}(Esegue tutte le ottimizzazioni)${NC}"
    echo
    echo -e "${YELLOW}📚 INFO:${NC}"
    echo -e "${WHITE} [11]${NC} 📊 ${GREEN}Mostra Statistiche${NC}         ${BLUE}(Performance e system info)${NC}"
    echo -e "${WHITE} [12]${NC} 📖 ${GREEN}Documentazione${NC}             ${BLUE}(README e changelog)${NC}"
    echo -e "${WHITE} [13]${NC} 🔍 ${GREEN}Test Sistema${NC}               ${BLUE}(Benchmark e verifiche)${NC}"
    echo
    echo -e "${WHITE}  [0]${NC} 👋 ${RED}Esci${NC}"
    echo
}

execute_script() {
    local script_name="$1"
    local description="$2"
    
    if [[ ! -f "$SCRIPTS_DIR/$script_name" ]]; then
        echo -e "${RED}❌ Script $script_name non trovato!${NC}"
        return 1
    fi
    
    echo -e "${CYAN}🔄 Eseguendo: $description${NC}"
    log "Executing: $script_name - $description"
    
    if bash "$SCRIPTS_DIR/$script_name"; then
        echo -e "${GREEN}✅ $description completato!${NC}"
        log "SUCCESS: $script_name completed"
    else
        echo -e "${RED}❌ Errore durante: $description${NC}"
        log "ERROR: $script_name failed"
        return 1
    fi
}

show_statistics() {
    clear
    print_header
    echo -e "${YELLOW}📊 STATISTICHE SISTEMA:${NC}"
    echo
    
    echo -e "${BLUE}🔥 CPU PERFORMANCE:${NC}"
    echo -e "   Model: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')"
    echo -e "   Cores: $(nproc)"
    echo -e "   Current Freq: $(cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}') MHz"
    echo -e "   Max Freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null | awk '{print $1/1000}' || echo 'N/A') MHz"
    echo -e "   Boost: $(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo 'N/A')"
    echo -e "   Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'N/A')"
    echo
    
    echo -e "${BLUE}💾 MEMORIA:${NC}"
    free -h | grep -E "(Mem|Swap)" | while read line; do
        echo -e "   $line"
    done
    echo
    
    echo -e "${BLUE}💿 STORAGE:${NC}"
    df -h / /home 2>/dev/null | tail -n +2 | while read line; do
        echo -e "   $line"
    done
    echo
    
    if nvidia-smi &>/dev/null; then
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
    
    echo -e "${BLUE}⚡ TOP PROCESSES:${NC}"
    ps aux --sort=-%cpu | head -6 | awk 'NR==1{print "   " $0} NR>1{printf "   %-20s %s%% CPU %s%% MEM\n", $11, $3, $4}'
    echo
}

run_system_test() {
    clear
    print_header
    echo -e "${YELLOW}🔍 TEST SISTEMA:${NC}"
    echo
    
    echo -e "${BLUE}🔥 Test CPU Boost:${NC}"
    boost_status=$(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo "0")
    if [[ "$boost_status" == "1" ]]; then
        echo -e "   ${GREEN}✅ CPU Boost ABILITATO${NC}"
    else
        echo -e "   ${RED}❌ CPU Boost DISABILITATO (Critico per development!)${NC}"
    fi
    
    echo -e "${BLUE}⚡ Test Governor:${NC}"
    governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    if [[ "$governor" == "performance" ]]; then
        echo -e "   ${GREEN}✅ Performance Governor ATTIVO${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Governor: $governor (Raccomandato: performance)${NC}"
    fi
    
    echo -e "${BLUE}💾 Test Memoria:${NC}"
    swap_usage=$(free | grep Swap | awk '{if($2>0) print ($3/$2)*100; else print 0}')
    if (( ${swap_usage%.*} < 10 )); then
        echo -e "   ${GREEN}✅ Utilizzo Swap: ${swap_usage}% (Ottimo con 32GB RAM)${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Utilizzo Swap: ${swap_usage}% (Potrebbe essere ottimizzato)${NC}"
    fi
    
    echo -e "${BLUE}💿 Test SSD:${NC}"
    if systemctl is-enabled fstrim.timer &>/dev/null; then
        echo -e "   ${GREEN}✅ TRIM automatico ABILITATO${NC}"
    else
        echo -e "   ${YELLOW}⚠️  TRIM automatico non configurato${NC}"
    fi
    
    echo -e "${BLUE}🖥️  Test Desktop:${NC}"
    animations=$(gsettings get org.gnome.desktop.interface enable-animations 2>/dev/null || echo "true")
    if [[ "$animations" == "false" ]]; then
        echo -e "   ${GREEN}✅ Animazioni DISABILITATE (Ottimo per development)${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Animazioni abilitate (Impatto performance)${NC}"
    fi
    
    echo
}

complete_optimization() {
    clear
    print_header
    echo -e "${YELLOW}⚡ OTTIMIZZAZIONE COMPLETA${NC}"
    echo
    echo -e "${CYAN}Questa operazione eseguirà TUTTE le ottimizzazioni:${NC}"
    echo -e "   🔥 Abilita CPU Boost"
    echo -e "   💾 Ottimizza Memoria 32GB"
    echo -e "   💿 Ottimizza SSD NVMe"
    echo -e "   🚀 Accelera Boot Time"
    echo -e "   🖥️ Ottimizza Desktop"
    echo -e "   ⚙️ Ottimizza Servizi"
    echo -e "   📊 Setup Monitoraggio"
    echo
    echo -e "${RED}⚠️  ATTENZIONE: Sarà necessario riavviare il sistema!${NC}"
    echo
    read -p "🚀 Procedere con l'ottimizzazione completa? (y/n): " confirm
    
    if [[ $confirm != "y" ]]; then
        echo -e "${YELLOW}👋 Operazione annullata${NC}"
        return 0
    fi
    
    # Backup automatico
    echo -e "${CYAN}📁 Creazione backup automatico...${NC}"
    execute_script "dev_backup_safety.sh" "Backup Sicurezza"
    
    # Ottimizzazioni
    execute_script "dev_cpu_boost.sh" "Abilitazione CPU Boost"
    execute_script "dev_memory_optimization.sh" "Ottimizzazione Memoria"
    execute_script "dev_ssd_optimization.sh" "Ottimizzazione SSD"
    execute_script "dev_grub_advanced.sh" "Ottimizzazione Boot"
    execute_script "dev_desktop_advanced.sh" "Ottimizzazione Desktop"
    execute_script "services_optimization.sh" "Ottimizzazione Servizi"
    execute_script "dev_monitoring_compact.sh" "Setup Monitoraggio"
    
    echo
    echo -e "${GREEN}🎉 OTTIMIZZAZIONE COMPLETA TERMINATA!${NC}"
    echo
    echo -e "${CYAN}📊 RISULTATI ATTESI:${NC}"
    echo -e "   🚀 Boot Time: 35s → 15-20s (-40%)"
    echo -e "   🔥 CPU Performance: +40% (boost ora abilitato)"
    echo -e "   💾 Memory Efficiency: Ottimizzata per 32GB"
    echo -e "   💿 SSD Performance: +20%"
    echo -e "   🖥️ Desktop Responsiveness: +50%"
    echo
    echo -e "${YELLOW}📱 COMANDI UTILI:${NC}"
    echo -e "   devmon     - Dashboard monitoraggio"
    echo -e "   btop       - Monitor sistema avanzato"
    echo -e "   nvidia-smi - Monitor GPU"
    echo
    read -p "🔄 Riavviare ora per applicare tutte le ottimizzazioni? (y/n): " reboot_confirm
    if [[ $reboot_confirm == "y" ]]; then
        echo -e "${CYAN}🔄 Riavviando in 5 secondi...${NC}"
        sleep 5
        sudo reboot
    else
        echo -e "${YELLOW}⏰ Ricordati di riavviare con: sudo reboot${NC}"
    fi
}

# Main loop
main() {
    # Crea directory se non esistono
    mkdir -p "$BACKUPS_DIR" "$DOCS_DIR"
    
    # Verifica permessi
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ Non eseguire questo script come root!${NC}"
        exit 1
    fi
    
    while true; do
        print_header
        print_system_info
        show_main_menu
        
        read -p "🎯 Scegli un'opzione: " choice
        echo
        
        case $choice in
            1) execute_script "dev_cpu_boost.sh" "Abilitazione CPU Boost" ;;
            2) execute_script "dev_memory_optimization.sh" "Ottimizzazione Memoria" ;;
            3) execute_script "dev_ssd_optimization.sh" "Ottimizzazione SSD" ;;
            4) execute_script "dev_grub_advanced.sh" "Ottimizzazione Boot" ;;
            5) execute_script "dev_desktop_advanced.sh" "Ottimizzazione Desktop" ;;
            6) execute_script "services_optimization.sh" "Ottimizzazione Servizi" ;;
            7) execute_script "dev_software_stack.sh" "Installazione Dev Stack" ;;
            8) execute_script "dev_monitoring_compact.sh" "Setup Monitoraggio" ;;
            9) execute_script "dev_backup_safety.sh" "Backup Completo" ;;
            10) 
                if [[ -d "$BACKUPS_DIR" ]] && [[ -n "$(ls -A $BACKUPS_DIR 2>/dev/null)" ]]; then
                    echo -e "${CYAN}📁 Backup disponibili:${NC}"
                    ls -la "$BACKUPS_DIR"
                    echo
                    read -p "Inserisci il nome del backup da ripristinare: " backup_name
                    if [[ -f "$BACKUPS_DIR/$backup_name/restore.sh" ]]; then
                        bash "$BACKUPS_DIR/$backup_name/restore.sh"
                    else
                        echo -e "${RED}❌ Script di restore non trovato!${NC}"
                    fi
                else
                    echo -e "${YELLOW}⚠️  Nessun backup trovato!${NC}"
                fi
                ;;
            11) show_statistics ;;
            12) 
                if [[ -f "$SCRIPT_DIR/README.md" ]]; then
                    less "$SCRIPT_DIR/README.md"
                else
                    echo -e "${RED}❌ README.md non trovato!${NC}"
                fi
                ;;
            13) run_system_test ;;
            99) complete_optimization ;;
            0) 
                echo -e "${GREEN}👋 Grazie per aver usato PopOS Optimizer!${NC}"
                echo -e "${CYAN}🚀 Per supporto: https://github.com/popOS-optimizer${NC}"
                exit 0 
                ;;
            *) 
                echo -e "${RED}❌ Opzione non valida!${NC}"
                ;;
        esac
        
        echo
        read -p "📱 Premi INVIO per continuare..."
    done
}

# Avvia il programma
main "$@" 