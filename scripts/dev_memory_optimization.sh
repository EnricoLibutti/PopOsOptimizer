#!/bin/bash
# Ottimizzazione memoria per Development (32GB RAM)

echo "=== OTTIMIZZAZIONE MEMORIA DEVELOPMENT ==="

# Ottimizzazioni specifiche per development con 32GB RAM
cat << 'EOF' | sudo tee -a /etc/sysctl.conf

# Ottimizzazioni Development - 32GB RAM
vm.swappiness=1                    # Quasi mai swap con 32GB
vm.vfs_cache_pressure=10          # Mantieni cache filesystem
vm.dirty_ratio=15                 # 15% di 32GB = ~5GB per write buffer
vm.dirty_background_ratio=5       # Background write a 5%
vm.dirty_expire_centisecs=1000    # Expiry veloce per responsività
vm.dirty_writeback_centisecs=100  # Writeback frequente per NVMe
vm.page-cluster=0                 # Riduce latenza per SSD
vm.overcommit_memory=1            # Ottimizza per development tools

# Ottimizzazioni scheduler per development
kernel.sched_min_granularity_ns=1000000    # 1ms granularità
kernel.sched_wakeup_granularity_ns=1000000 # 1ms wakeup
kernel.sched_migration_cost_ns=500000      # 0.5ms migration
kernel.sched_latency_ns=6000000            # 6ms latenza
kernel.sched_nr_migrate=128                # Più migration
kernel.sched_rr_timeslice_ms=25            # 25ms time slice

# Ottimizzazioni network per development
net.core.rmem_max=268435456
net.core.wmem_max=268435456
net.ipv4.tcp_rmem=4096 87380 268435456
net.ipv4.tcp_wmem=4096 65536 268435456
EOF

# Configurazione ZRAM per development (compressione intelligente)
echo 'ALGORITHM=lz4' | sudo tee -a /etc/systemd/zram-generator.conf
echo 'SIZE=4G' | sudo tee -a /etc/systemd/zram-generator.conf
echo 'PRIORITY=10' | sudo tee -a /etc/systemd/zram-generator.conf

# Ricarica configurazioni
sudo sysctl -p

echo "✅ Memoria ottimizzata per development - 32GB utilizzati al meglio" 