#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

trap 'log_error "User-level update failed (line $LINENO)."; exit 1' ERR

require_not_root

# User-level updates
# This script updates user-installed tools

log_info "Starting user-level updates..."

# Update Atuin
update_atuin

trap - ERR
log_info "User-level updates complete!"
