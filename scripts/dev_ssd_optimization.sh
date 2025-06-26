#!/bin/bash
# Ottimizzazione SSD NVMe per Development

echo "=== OTTIMIZZAZIONE SSD NVME PER DEVELOPMENT ==="

# Verifica TRIM è abilitato
echo "Stato TRIM attuale:"
sudo fstrim -v /
sudo fstrim -v /home

# Abilita TRIM automatico
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

# Ottimizza scheduler I/O per NVMe (mq-deadline è ottimo per development)
echo "Configurando scheduler I/O per development..."
echo 'ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="mq-deadline"' | sudo tee /etc/udev/rules.d/60-nvme-scheduler.rules

# Ottimizzazioni kernel per NVMe development
cat << 'EOF' | sudo tee -a /etc/sysctl.conf

# Ottimizzazioni NVMe Development
vm.dirty_bytes=268435456          # 256MB dirty buffer
vm.dirty_background_bytes=134217728  # 128MB background
fs.file-max=2097152               # Più file aperti per development
fs.inotify.max_user_watches=524288   # Per file watchers (webpack, etc)
fs.inotify.max_user_instances=256
fs.inotify.max_queued_events=32768
EOF

# Configurazione fstab per development (se non già presente)
sudo cp /etc/fstab /etc/fstab.backup

# Verifica mount options attuali
echo "Mount options attuali:"
mount | grep nvme

# Ottimizzazioni aggiuntive per development
echo "Configurando read-ahead per development..."
sudo blockdev --setra 4096 /dev/nvme0n1

# Script per ottimizzare read-ahead al boot
cat << 'EOF' | sudo tee /etc/systemd/system/nvme-readahead.service
[Unit]
Description=Optimize NVMe read-ahead for development
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/sbin/blockdev --setra 4096 /dev/nvme0n1
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable nvme-readahead.service

echo "✅ SSD NVMe ottimizzato per development workloads" 