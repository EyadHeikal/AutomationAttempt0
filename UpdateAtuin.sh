#!/bin/bash

set -e
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Update Atuin
if command -v atuin &>/dev/null; then
    log_info "Updating Atuin..."
    atuin update || log_warn "Atuin update failed"
else
    log_warn "Atuin not found, skipping update"
fi

