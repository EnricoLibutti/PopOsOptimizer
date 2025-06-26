#!/bin/bash
# Sistema di monitoraggio Development (versione compatta)

echo "=== CONFIGURAZIONE MONITORAGGIO DEVELOPMENT ==="

# Installa strumenti di monitoraggio
sudo apt install -y htop btop iotop nethogs ncdu glances

# Script monitoraggio compatto
cat << 'EOF' > ~/dev_monitor.sh
#!/bin/bash
clear
echo "🖥️  DEVELOPMENT WORKSTATION MONITOR - $(date)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🔧 SISTEMA: $(hostname) | $(uptime -p) | Load: $(uptime | awk -F'load average:' '{print $2}')"

echo "🔥 CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//' | cut -c1-30)..."
echo "   Cores: $(nproc) | Freq: $(cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}') MHz"
echo "   Boost: $(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo 'N/A') | Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'N/A')"

echo "💾 MEMORIA:"
free -h | grep -E "(Mem|Swap)"

echo "💿 STORAGE:"
df -h / /home 2>/dev/null | tail -n +2

if nvidia-smi &>/dev/null; then
    echo "🎮 GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader,nounits)"
    echo "   Temp: $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)°C | Usage: $(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)%"
fi

echo "⚡ TOP DEVELOPMENT PROCESSES:"
ps aux --sort=-%cpu | grep -E "(code|cursor|firefox|node|npm|docker|python|java)" | head -5 | awk '{printf "   %-20s %s%% CPU %s%% MEM\n", $11, $3, $4}'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 btop | 🎮 nvidia-smi | 💾 iotop | 🌐 nethogs"
EOF

chmod +x ~/dev_monitor.sh

# Alias monitoraggio
cat << 'EOF' >> ~/.bashrc

# Development Monitoring
alias devmon='~/dev_monitor.sh'
alias cpumon='watch -n 1 "grep MHz /proc/cpuinfo"'
alias gpumon='watch -n 1 nvidia-smi'
alias diskmon='watch -n 1 "df -h | grep -E \"(/$|/home)\""'
EOF

echo "✅ Monitoraggio development configurato - usa 'devmon'" 