#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

trap 'log_error "User-level setup failed (line $LINENO)."; exit 1' ERR

require_not_root

# User-level installations and configurations
# This script installs tools that don't require system-level privileges

log_info "Starting user-level setup..."

# Install Atuin
install_atuin
# Install Ruby
install_ruby
# Link dotfiles (shell configs, gitconfig, etc.)
bash "$SCRIPT_DIR/LinkDotFiles.sh"

trap - ERR
log_info "User-level setup complete!"
log_info "Please restart your shell or source your shell configuration file for changes to take effect"
