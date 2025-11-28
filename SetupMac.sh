#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

trap 'log_error "Setup failed (line $LINENO). Check the logs above for details."; exit 1' ERR

BREWFILE="$SCRIPT_DIR/Brewfile"

require_not_root
require_command "xcode-select" "Install Xcode Command Line Tools from Apple."
require_command "curl" "curl is required for bootstrapping external installers."

if [[ ! -f "$BREWFILE" ]]; then
    die "Brewfile not found at $BREWFILE"
fi

ensure_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || die "Homebrew installation failed"
    else
        log_info "Homebrew already installed"
    fi

    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(brew shellenv)"
    fi
}

ensure_xcode_cli() {
    if ! xcode-select -p &>/dev/null; then
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        log_warn "Please complete the Xcode CLI tools installation and re-run this script."
        trap - ERR
        exit 0
    fi
}

install_brewfile_packages() {
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_DISPLAY_INSTALL_TIMES=1
    export NONINTERACTIVE=1

    log_info "Installing packages from Brewfile..."
    if ! brew bundle install --cleanup --file="$BREWFILE"; then
        log_warn "Some Homebrew packages may have failed to install"
    fi
}

configure_file_associations() {
    if command -v duti >/dev/null 2>&1; then
        log_info "Configuring file associations..."
        local ext
        for ext in avi mkv mp4 mov mp3; do
            if ! duti -s io.mpv "$ext" all 2>/dev/null; then
                log_warn "Failed to set $ext association"
            fi
        done
    else
        log_warn "duti is not available; skipping file association configuration"
    fi
}

install_npm_packages() {
    if command -v npm >/dev/null 2>&1; then
        log_info "Installing npm packages..."
        if ! npm install -g @kilocode/cli; then
            log_warn "Some npm packages failed to install"
        fi
    else
        log_warn "npm not found; skipping global npm packages"
    fi
}

install_netbird() {
    if ! command -v netbird >/dev/null 2>&1; then
        log_info "Installing NetBird..."
        if curl -fsSL https://pkgs.netbird.io/install.sh | sh; then
            log_info "Connecting to NetBird..."
            if ! netbird up --management-url https://netbird-mgmt.instabug.tools:33073; then
                log_warn "NetBird connection failed"
            fi
        else
            log_warn "NetBird installation failed"
        fi
    else
        log_info "NetBird already installed"
    fi
}


ensure_xcode_cli
ensure_homebrew
install_brewfile_packages

install_atuin
configure_file_associations
install_proxyman_components
install_npm_packages
install_netbird

log_info "Cleaning up..."
if ! brew cleanup --prune=all; then
    log_warn "brew cleanup encountered issues"
fi

if ! rm -rf "$(brew --cache)"; then
    log_warn "Failed to clear Homebrew cache"
fi

trap - ERR
log_info "Setup complete!"
