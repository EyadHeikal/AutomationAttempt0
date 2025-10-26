#!/bin/bash

set -e
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# User-level updates
# This script updates user-installed tools

log_info "Starting user-level updates..."

# Update Atuin
"$SCRIPT_DIR/UpdateAtuin.sh"

log_info "User-level updates complete!"

