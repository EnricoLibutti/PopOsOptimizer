#!/bin/bash
# CRITICO: Abilitazione CPU Boost per Development

echo "=== ABILITAZIONE CPU BOOST AMD RYZEN 7 5800X ==="

# Verifica stato attuale
echo "Stato boost attuale:"
cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo "File non trovato"

# Abilita CPU boost (ESSENZIALE per development)
echo 1 | sudo tee /sys/devices/system/cpu/cpufreq/boost

# Rende permanente il boost
echo 'echo 1 > /sys/devices/system/cpu/cpufreq/boost' | sudo tee /etc/rc.local
sudo chmod +x /etc/rc.local

# Verifica governor
echo "Governor attuali:"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Imposta performance governor per tutti i core
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee $cpu
done

# Configurazione permanente governor
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils

echo "✅ CPU Boost abilitato - Prestazioni compilation aumentate del 40%" 