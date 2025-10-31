#!/bin/bash

set -e
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# User-level installations and configurations
# This script installs tools that don't require system-level privileges

log_info "Starting user-level setup..."

# Install Atuin
"$SCRIPT_DIR/InstallAtuin.sh"

# Link shell configuration files
"$SCRIPT_DIR/LinkShellConfigs.sh"

log_info "User-level setup complete!"
log_info "Please restart your shell or source your shell configuration file for changes to take effect"
