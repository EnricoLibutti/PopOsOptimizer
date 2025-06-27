#!/bin/bash
# -----------------------------------------------------------------------------
# Software Stack Installer
# -----------------------------------------------------------------------------
# This script installs and configures a development software stack based on
# settings in config.sh.
#
# What it does:
# - Updates and upgrades the system.
# - Removes specified unnecessary packages.
# - Installs essential development tools, languages, and runtimes.
# - Installs Docker and adds the current user to the docker group.
# - Configures Git globally (optional).
# - Configures NPM and Python for development.
# - Adds useful development aliases to ~/.bashrc.
# -----------------------------------------------------------------------------

set -e

# --- Load Configuration ---
source "$(dirname "$0")/config.sh"

# --- Helper Functions ---
log_info() {
    echo "[INFO] $1"
}

log_success() {
    echo "[SUCCESS] $1"
}

log_warning() {
    echo "[WARNING] $1"
}

# --- Main Functions ---

# Updates and upgrades the system
update_system() {
    log_info "Updating and upgrading system packages..."
    sudo apt update && sudo apt upgrade -y
    log_success "System packages updated and upgraded."
}

# Removes unnecessary packages
remove_unnecessary_packages() {
    if [ ${#PACKAGES_TO_REMOVE[@]} -eq 0 ]; then
        log_info "No packages specified for removal. Skipping."
        return
    fi

    log_info "Removing unnecessary packages: ${PACKAGES_TO_REMOVE[*]}..."
    sudo apt autoremove -y "${PACKAGES_TO_REMOVE[@]}"
    log_success "Unnecessary packages removed."
}

# Installs essential development tools
install_dev_packages() {
    if [ ${#DEV_PACKAGES_TO_INSTALL[@]} -eq 0 ]; then
        log_info "No development packages specified for installation. Skipping."
        return
    fi

    log_info "Installing essential development packages: ${DEV_PACKAGES_TO_INSTALL[*]}..."
    sudo apt install -y "${DEV_PACKAGES_TO_INSTALL[@]}"
    log_success "Development packages installed."
}

# Installs and configures Docker
install_docker() {
    log_info "Installing Docker..."
    # Check if Docker is already installed
    if command -v docker &> /dev/null; then
        log_info "Docker is already installed. Skipping installation."
    else
        # Add Docker's official GPG key:
        sudo apt-get update
        sudo apt-get install ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Add the repository to Apt sources:
        echo \
          "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    fi

    # Add current user to docker group
    if ! getent group docker | grep &>/dev/null "\b$USER\b"; then
        log_info "Adding current user to 'docker' group..."
        sudo usermod -aG docker "$USER"
        log_warning "You need to log out and log back in for Docker group changes to take effect."
    else
        log_info "User '$USER' is already in the 'docker' group."
    fi
    log_success "Docker installed and configured."
}

# Configures Git globally
configure_git() {
    log_info "Configuring Git globally..."
    read -p "Enter your Git username (e.g., John Doe): " git_name
    read -p "Enter your Git email (e.g., john.doe@example.com): " git_email

    if [[ -n "$git_name" && -n "$git_email" ]]; then
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        git config --global core.editor nano
        log_success "Git configured with user: $git_name <$git_email>."
    else
        log_warning "Git configuration skipped due to empty input."
    fi
}

# Configures NPM for development
configure_npm() {
    log_info "Configuring NPM..."
    npm config set fund false
    npm config set audit false
    npm config set save-exact true
    log_success "NPM configured."
}

# Configures Python for development
configure_python() {
    log_info "Configuring Python..."
    pip3 install --user pipenv poetry black flake8 mypy pytest
    log_success "Python development tools installed."
}

# Adds useful development aliases to ~/.bashrc
add_dev_aliases() {
    log_info "Adding development aliases to ~/.bashrc..."
    local aliases_block="
# --- Development Aliases ---
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
alias cat='batcat' # Requires batcat to be installed
alias find='fd'    # Requires fd-find to be installed
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

# Development specific aliases
alias serve='python3 -m http.server'
alias myip='curl -s https://ipinfo.io/ip'
alias ports='netstat -tulanp'
alias dockerclean='docker system prune -af'
# --- End Development Aliases ---
"

    # Check if aliases block already exists to prevent duplication
    if ! grep -q "# --- Development Aliases ---" ~/.bashrc; then
        echo "$aliases_block" >> ~/.bashrc
        log_success "Development aliases added to ~/.bashrc."
        log_warning "Please restart your terminal or run 'source ~/.bashrc' to apply aliases."
    else
        log_info "Development aliases already exist in ~/.bashrc. Skipping."
    fi
}

# --- Execution ---
echo "🚀 Running Software Stack Installer..."

update_system
remove_unnecessary_packages
install_dev_packages
install_docker
configure_git
configure_npm
configure_python
add_dev_aliases

echo "✅ Software stack installation and configuration complete."
