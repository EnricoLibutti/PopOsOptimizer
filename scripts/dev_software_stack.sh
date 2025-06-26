#!/bin/bash
# Software Stack per Development

echo "=== INSTALLAZIONE SOFTWARE DEVELOPMENT STACK ==="

# Aggiorna sistema
sudo apt update && sudo apt upgrade -y

# Rimuovi software non necessario per development
echo "Rimuovendo software non necessario..."
sudo apt autoremove -y totem rhythmbox simple-scan gnome-todo geary

# Installa strumenti development essenziali
echo "Installando strumenti development..."
sudo apt install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    vim \
    neovim \
    curl \
    wget \
    htop \
    btop \
    tree \
    jq \
    httpie \
    unzip \
    zip \
    p7zip-full \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Installa linguaggi e runtime
echo "Installando linguaggi e runtime..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    default-jdk \
    golang-go \
    rustc \
    cargo

# Installa Docker (essenziale per development moderno)
echo "Installando Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER

# Installa strumenti monitoring per development
sudo apt install -y \
    iotop \
    nethogs \
    ncdu \
    lm-sensors \
    stress-ng \
    sysbench

# Configura Git globalmente (se non già fatto)
read -p "Configura Git? (y/n): " setup_git
if [[ $setup_git == "y" ]]; then
    read -p "Nome: " git_name
    read -p "Email: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global core.editor nano
fi

# Ottimizzazioni NPM per development
echo "Ottimizzando NPM..."
npm config set fund false
npm config set audit false
npm config set fund false
npm config set save-exact true

# Configura Python per development
echo "Configurando Python..."
pip3 install --user pipenv poetry black flake8 mypy pytest

# Alias utili per development
cat << 'EOF' >> ~/.bashrc

# Alias Development
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias top='btop'
alias cat='batcat'
alias find='fd'
alias ps='ps auxf'
alias mkdir='mkdir -pv'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# Development aliases
alias serve='python3 -m http.server'
alias myip='curl -s https://ipinfo.io/ip'
alias ports='netstat -tulanp'
alias dockerclean='docker system prune -af'
EOF

echo "✅ Software development stack installato e configurato"
echo "📝 Riavvia il terminale per applicare gli alias" 