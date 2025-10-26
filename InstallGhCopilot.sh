#!/bin/bash

set -e
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Install GitHub Copilot extension
log_info "Installing gh-copilot extension..."
gh extension install github/gh-copilot || log_warn "gh-copilot installation failed"

