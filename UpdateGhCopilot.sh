#!/bin/bash

set -e
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Update GitHub Copilot extension
log_info "Updating gh-copilot extension..."
gh extension upgrade gh-copilot || log_warn "gh-copilot upgrade failed"

