#!/bin/bash
# Ottimizzazioni Desktop Environment per Development

echo "=== OTTIMIZZAZIONI DESKTOP DEVELOPMENT ==="

# Disabilita effetti grafici non necessari per development
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.interface gtk-enable-animations false
gsettings set org.gnome.shell.extensions.dash-to-dock animate-show-apps false
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0

# Ottimizzazioni per multitasking development
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
gsettings set org.gnome.desktop.wm.preferences focus-mode 'click'
gsettings set org.gnome.desktop.wm.preferences auto-raise false
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 6

# Ottimizzazioni per IDE e editor
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab']"

# Configurazioni per development workflow
gsettings set org.gnome.desktop.session idle-delay 1800  # 30 min (non disturbare durante debug)
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'

# Ottimizzazioni per terminal
gsettings set org.gnome.desktop.default-applications.terminal exec 'gnome-terminal'

# Configurazioni per file manager ottimizzate per development
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gnome.nautilus.preferences show-directory-item-counts 'always'
gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'

# Ottimizzazioni notifiche (meno distrazioni durante coding)
gsettings set org.gnome.desktop.notifications show-banners false
gsettings set org.gnome.desktop.notifications show-in-lock-screen false

# Configurazioni Pop Shell per development
gsettings set org.gnome.shell.extensions.pop-shell tile-by-default true
gsettings set org.gnome.shell.extensions.pop-shell show-title false
gsettings set org.gnome.shell.extensions.pop-shell smart-gaps true
gsettings set org.gnome.shell.extensions.pop-shell gap-inner 2
gsettings set org.gnome.shell.extensions.pop-shell gap-outer 2

# Disabilita servizi tracker per prestazioni (file indexing non necessario)
systemctl --user mask tracker-store.service
systemctl --user mask tracker-miner-fs.service
systemctl --user mask tracker-extract.service
systemctl --user stop tracker-store.service 2>/dev/null || true
systemctl --user stop tracker-miner-fs.service 2>/dev/null || true

# Configurazione font per development
gsettings set org.gnome.desktop.interface monospace-font-name 'Fira Code Medium 11'
gsettings set org.gnome.desktop.interface font-name 'Ubuntu 10'
gsettings set org.gnome.desktop.interface document-font-name 'Ubuntu 10'

echo "✅ Desktop ottimizzato per development workflow" 