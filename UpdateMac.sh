#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

trap 'log_error "System update failed (line $LINENO)."; exit 1' ERR

require_not_root
require_command "brew" "Install Homebrew before running system updates."

log_info "Updating Homebrew..."
if ! brew update; then
    log_warn "brew update encountered issues"
fi

log_info "Checking for outdated formulae..."
OUTDATED_FORMULAE=""
if ! OUTDATED_FORMULAE="$(brew outdated)"; then
    log_warn "Unable to list outdated formulae"
    OUTDATED_FORMULAE=""
fi
if [[ -n "$OUTDATED_FORMULAE" ]]; then
    printf '%s\n' "$OUTDATED_FORMULAE"
fi

log_info "Checking for outdated casks..."
OUTDATED_CASKS=""
if ! OUTDATED_CASKS="$(brew outdated --cask --greedy)"; then
    log_warn "Unable to list outdated casks"
    OUTDATED_CASKS=""
fi
if [[ -n "$OUTDATED_CASKS" ]]; then
    printf '%s\n' "$OUTDATED_CASKS"
fi

if [[ -z "$OUTDATED_FORMULAE" && -z "$OUTDATED_CASKS" ]]; then
    log_info "All Homebrew packages are up to date."
else
    read -r -p "Proceed with upgrade? (y/N): " -n 1
    echo
    if [[ ! ${REPLY:-} =~ ^[Yy]$ ]]; then
        log_warn "Update cancelled"
        trap - ERR
        exit 0
    fi

    if [[ -n "$OUTDATED_FORMULAE" ]]; then
        log_info "Upgrading brew formulae..."
        if ! brew upgrade --greedy -f; then
            log_warn "brew upgrade for formulae encountered issues"
        fi
    fi

    if [[ -n "$OUTDATED_CASKS" ]]; then
        log_info "Upgrading brew casks..."
        if ! brew upgrade --cask --greedy -f; then
            log_warn "brew cask upgrade encountered issues"
        fi
    fi
fi

install_proxyman_components

log_info "Upgrading mise-managed tools..."
mise upgrade || log_warn "mise upgrade encountered issues"
mise cache prune || log_warn "mise cache prune encountered issues"
mise cache clear || log_warn "mise cache clear encountered issues"

log_info "Cleaning up..."
if ! brew cleanup --prune=all; then
    log_warn "brew cleanup encountered issues"
fi

update_atuin

if ! npm update -g; then
    log_warn "npm update -g encountered issues"
fi

if ! yarn global upgrade; then
    log_warn "yarn global upgrade encountered issues"
fi

if command -v mas >/dev/null 2>&1; then
    log_info "Checking Mac App Store updates..."
    mas outdated || log_warn "mas outdated failed"
else
    log_warn "mas command not available; skipping Mac App Store update check"
fi

if ! mas upgrade; then
    log_warn "mas upgrade encountered issues"
fi

log_info "Checking for macOS updates..."
if ! softwareupdate -l; then
    log_warn "softwareupdate -l encountered issues"
fi


trap - ERR
log_info "Update complete!"
log_info "To install macOS updates, run: softwareupdate -i -a"
