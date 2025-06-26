#!/bin/bash
# Sistema di monitoraggio per Development Workstation

echo "=== CONFIGURAZIONE MONITORAGGIO DEVELOPMENT ==="

# Installa strumenti di monitoraggio avanzati
sudo apt install -y htop btop iotop nethogs ncdu glances

# Script monitoraggio development personalizzato
cat << 'EOF' > ~/dev_monitor.sh
#!/bin/bash
# Development Workstation Monitor

clear
 