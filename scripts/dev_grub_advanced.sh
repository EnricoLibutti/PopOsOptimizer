#!/bin/bash
# Ottimizzazioni GRUB avanzate per Development

echo "=== OTTIMIZZAZIONI GRUB AVANZATE DEVELOPMENT ==="

# Backup configurazione
sudo cp /etc/default/grub /etc/default/grub.dev-backup

# Configurazione GRUB ottimizzata per development
cat << 'EOF' | sudo tee /etc/default/grub
# Configurazione GRUB Development Workstation
GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=2
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`

# Parametri kernel ottimizzati per development
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amd_pstate=active cpufreq.default_governor=performance mitigations=off nowatchdog nmi_watchdog=0 audit=0 mce=ignore_ce processor.max_cstate=1 intel_idle.max_cstate=0 idle=poll rcu_nocbs=0-15 isolcpus=nohz,domain,managed_irq,0-1 nohz_full=2-15 irqaffinity=0,1"

GRUB_CMDLINE_LINUX=""

# Ottimizzazioni boot
GRUB_RECORDFAIL_TIMEOUT=1
GRUB_DISABLE_SUBMENU=y
GRUB_DISABLE_OS_PROBER=true

# Theme veloce
GRUB_THEME="/boot/grub/themes/pop/theme.txt"
GRUB_GFXMODE="1920x1080"
GRUB_GFXPAYLOAD_LINUX="keep"
EOF

# Aggiorna GRUB
sudo update-grub

# Ottimizzazioni initramfs per boot veloce
echo "Ottimizzando initramfs..."
cat << 'EOF' | sudo tee -a /etc/initramfs-tools/modules
# Moduli development
amd64_edac_mod
kvm_amd
EOF

# Rimuovi moduli non necessari per development desktop
cat << 'EOF' | sudo tee /etc/initramfs-tools/conf.d/development
# Configurazione development
MODULES=dep
COMPRESS=lz4
EOF

sudo update-initramfs -u -k all

echo "✅ GRUB ottimizzato - Boot time target: 15-18 secondi" 