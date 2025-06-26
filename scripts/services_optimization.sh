#!/bin/bash
# Script ottimizzazione servizi Pop!_OS

echo "=== OTTIMIZZAZIONE SERVIZI ==="

# Servizi da disabilitare per development workstation
SERVICES_TO_DISABLE=(
    "plymouth-quit-wait.service"  # Boot grafico non necessario
    "NetworkManager-wait-online.service"  # Rallenta il boot
    "cups-browsed.service"  # Se non usi stampanti di rete
    "avahi-daemon.service"  # Se non usi discovery di rete
)

# Disabilita servizi non necessari
for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl is-enabled "$service" >/dev/null 2>&1; then
        echo "Disabilitando $service..."
        sudo systemctl disable "$service"
        sudo systemctl mask "$service"
    fi
done

# Ottimizzazioni specifiche per development
echo "=== OTTIMIZZAZIONI DEVELOPMENT ==="

# Aumenta limite file per development
echo "fs.file-max = 65536" | sudo tee -a /etc/sysctl.conf
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Ottimizzazioni memoria
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf

echo "Ottimizzazione servizi completata!" 