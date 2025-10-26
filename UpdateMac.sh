#!/bin/bash

set -e
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Update Homebrew
log_info "Updating Homebrew..."
brew update

# Check for outdated packages
log_info "Checking for outdated formulae..."
OUTDATED_FORMULAE=$(brew outdated)
if [[ -n "$OUTDATED_FORMULAE" ]]; then
    echo "$OUTDATED_FORMULAE"
fi

log_info "Checking for outdated casks..."
OUTDATED_CASKS=$(brew outdated --cask --greedy)
if [[ -n "$OUTDATED_CASKS" ]]; then
    echo "$OUTDATED_CASKS"
fi

# Check if there are any updates available
if [[ -z "$OUTDATED_FORMULAE" && -z "$OUTDATED_CASKS" ]]; then
    log_info "All packages are up to date!"
else
    # Ask for confirmation
    read -p "Proceed with upgrade? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Update cancelled"
        exit 0
    fi

    # Upgrade packages
    if [[ -n "$OUTDATED_FORMULAE" ]]; then
        log_info "Upgrading brew packages..."
        brew upgrade --greedy -f
    fi

    if [[ -n "$OUTDATED_CASKS" ]]; then
        log_info "Upgrading casks..."
        brew upgrade --cask --greedy -f
    fi
fi

# Reinstall Proxyman privileged components after upgrade
"$SCRIPT_DIR/InstallProxymanComponents.sh"

# Cleanup
log_info "Cleaning up..."
brew cleanup --prune=all

# Update gh extensions
"$SCRIPT_DIR/UpdateGhCopilot.sh"

# Update Atuin
"$SCRIPT_DIR/UpdateAtuin.sh"

# Check Mac App Store updates
log_info "Checking Mac App Store updates..."
mas outdated

# Check for macOS updates
log_info "Checking for macOS updates..."
softwareupdate -l

log_info "Update complete!"
log_info "To install Mac App Store updates, run: mas upgrade"
log_info "To install macOS updates, run: softwareupdate -i -a"
