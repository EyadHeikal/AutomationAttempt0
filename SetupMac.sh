#!/bin/bash

# Strict error handling
set -e
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Check if running as root (shouldn't be)
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root"
   exit 1
fi

# Install Xcode Command Line Tools if not present
if ! xcode-select -p &>/dev/null; then
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    log_warn "Please complete the Xcode CLI tools installation and re-run this script"
    exit 0
fi

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        log_error "Homebrew installation failed"
        exit 1
    }
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    log_info "Homebrew already installed"
fi

# Set Homebrew environment variables
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
export NONINTERACTIVE=1

# Install packages from Brewfile
log_info "Installing packages from Brewfile..."
brew bundle install --cleanup || log_error "Some brew packages failed to install"

# Install GitHub Copilot extension
"$SCRIPT_DIR/InstallGhCopilot.sh"

# Install Atuin
"$SCRIPT_DIR/InstallAtuin.sh"

# Configure file associations
log_info "Configuring file associations..."
for ext in avi mkv mp4 mov mp3; do
    duti -s io.mpv "$ext" all 2>/dev/null || log_warn "Failed to set $ext association"
done

# Install Proxyman privileged components
"$SCRIPT_DIR/InstallProxymanComponents.sh"

# Install npm packages
log_info "Installing npm packages..."
npm install -g @anthropic-ai/claude-code || log_warn "Some npm packages failed"

# Install NetBird
if ! command -v netbird &>/dev/null; then
    log_info "Installing NetBird..."
    curl -fsSL https://pkgs.netbird.io/install.sh | sh || log_warn "NetBird installation failed"
    
    # Use default netbird management URL
    log_info "Connecting to NetBird..."
    netbird up --management-url https://netbird-mgmt.instabug.tools:33073 || log_warn "NetBird connection failed"
else
    log_info "NetBird already installed"
fi

# Install Cursor
if ! command -v cursor-agent &>/dev/null; then
    log_info "Installing Cursor..."
    curl https://cursor.com/install -fsS | bash || log_warn "Cursor installation failed"
else
    log_info "Cursor already installed"
fi

# Cleanup
log_info "Cleaning up..."
brew cleanup --prune=all

log_info "Setup complete!"
