#!/bin/bash

set -e
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Install Proxyman privileged components
if [[ -d "/Applications/Proxyman.app" ]]; then
    # Check if helper tool is already installed
    # Proxyman installs its privileged helper tool to /Library/PrivilegedHelperTools/
    if [[ -e "/Library/PrivilegedHelperTools/com.proxyman.NSProxy.HelperTool" ]]; then
        log_info "Proxyman privileged components already installed"
    else
        log_info "Installing Proxyman privileged components..."
        sudo /Applications/Proxyman.app/Contents/MacOS/proxyman --install-privileged-components || log_warn "Proxyman privileged components installation failed"
    fi
else
    log_warn "Proxyman not found, skipping privileged components installation"
fi

