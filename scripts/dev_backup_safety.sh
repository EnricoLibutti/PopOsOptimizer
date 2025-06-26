#!/bin/bash
# Backup e precauzioni per ottimizzazioni development

echo "=== BACKUP E PRECAUZIONI DEVELOPMENT ==="

# Crea directory backup
BACKUP_DIR="./backup/dev_optimization_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Backup in: $BACKUP_DIR"

# Backup configurazioni critiche
echo "💾 Backup configurazioni critiche..."
sudo cp /etc/default/grub "$BACKUP_DIR/grub.backup" 2>/dev/null || echo "GRUB backup failed"
sudo cp /etc/fstab "$BACKUP_DIR/fstab.backup" 2>/dev/null || echo "FSTAB backup failed"
sudo cp /etc/sysctl.conf "$BACKUP_DIR/sysctl.backup" 2>/dev/null || echo "SYSCTL backup failed"
cp ~/.bashrc "$BACKUP_DIR/bashrc.backup" 2>/dev/null || echo "BASHRC backup failed"

# Backup configurazioni GNOME/desktop
echo "🖥️ Backup configurazioni desktop..."
dconf dump /org/gnome/ > "$BACKUP_DIR/gnome_settings.backup"

# Lista servizi attuali
echo "🔧 Backup lista servizi..."
systemctl list-unit-files --state=enabled > "$BACKUP_DIR/enabled_services.list"
systemctl list-units --type=service --state=running > "$BACKUP_DIR/running_services.list"

# Lista pacchetti installati
echo "📦 Backup lista pacchetti..."
apt list --installed > "$BACKUP_DIR/installed_packages.list" 2>/dev/null
flatpak list > "$BACKUP_DIR/flatpak_packages.list" 2>/dev/null || echo "No flatpak"

# Informazioni sistema pre-ottimizzazione
echo "📊 Salvataggio stato sistema..."
cat << EOF > "$BACKUP_DIR/system_info.txt"
=== STATO SISTEMA PRE-OTTIMIZZAZIONE ===
Data: $(date)
Hostname: $(hostname)
Kernel: $(uname -r)
CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2)
RAM: $(free -h | grep Mem | awk '{print $2}')
GPU: $(lspci | grep VGA)
Boot time: $(systemd-analyze | head -1)
Uptime: $(uptime)
EOF

# Benchmark pre-ottimizzazione
echo "⚡ Benchmark pre-ottimizzazione..."
if command -v sysbench &> /dev/null; then
    sysbench cpu --threads=8 run > "$BACKUP_DIR/cpu_benchmark_pre.txt" 2>&1 || echo "CPU benchmark failed"
fi

# Script di restore
cat << 'EOF' > "$BACKUP_DIR/restore.sh"
#!/bin/bash
# Script di ripristino configurazioni

echo "=== RIPRISTINO CONFIGURAZIONI ==="
BACKUP_DIR="$(dirname "$0")"

read -p "Ripristinare GRUB? (y/n): " restore_grub
if [[ $restore_grub == "y" ]]; then
    sudo cp "$BACKUP_DIR/grub.backup" /etc/default/grub
    sudo update-grub
    echo "✅ GRUB ripristinato"
fi

read -p "Ripristinare SYSCTL? (y/n): " restore_sysctl
if [[ $restore_sysctl == "y" ]]; then
    sudo cp "$BACKUP_DIR/sysctl.backup" /etc/sysctl.conf
    sudo sysctl -p
    echo "✅ SYSCTL ripristinato"
fi

read -p "Ripristinare BASHRC? (y/n): " restore_bashrc
if [[ $restore_bashrc == "y" ]]; then
    cp "$BACKUP_DIR/bashrc.backup" ~/.bashrc
    echo "✅ BASHRC ripristinato"
fi

read -p "Ripristinare configurazioni GNOME? (y/n): " restore_gnome
if [[ $restore_gnome == "y" ]]; then
    dconf load /org/gnome/ < "$BACKUP_DIR/gnome_settings.backup"
    echo "✅ Configurazioni GNOME ripristinate"
fi

echo "🔄 Riavvia il sistema per applicare le modifiche"
EOF

chmod +x "$BACKUP_DIR/restore.sh"

# Checklist sicurezza
cat << EOF > "$BACKUP_DIR/CHECKLIST.md"
# 📋 CHECKLIST OTTIMIZZAZIONI DEVELOPMENT

## Prima di applicare le ottimizzazioni:
- [ ] Backup completato in: $BACKUP_DIR
- [ ] Sistema aggiornato
- [ ] Progetti importanti salvati/committati
- [ ] Chiuse tutte le applicazioni critiche

## Dopo le ottimizzazioni:
- [ ] Riavvio sistema
- [ ] Verifica boot time migliorato
- [ ] Test funzionalità principali
- [ ] Monitoraggio prestazioni con 'devmon'

## In caso di problemi:
- Esegui: bash $BACKUP_DIR/restore.sh
- Riavvia in modalità recovery se necessario
- Ripristina dal backup GRUB se boot fallisce

## Ottimizzazioni attese:
- Boot time: 35s → 15-20s
- CPU boost: ABILITATO
- Performance governor: ATTIVO
- Memoria ottimizzata per 32GB
- Desktop responsivo
EOF

echo "✅ Backup completato in: $BACKUP_DIR"
echo "📋 Leggi: $BACKUP_DIR/CHECKLIST.md"
echo "🔄 Per ripristino: bash $BACKUP_DIR/restore.sh" 