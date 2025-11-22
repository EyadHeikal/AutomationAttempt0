#!/usr/bin/env bash
# shellcheck shell=bash

# Common utilities for Mac setup scripts

# shellcheck disable=SC2034 # Used by sourcing scripts for colored output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

_log() {
    # Usage: _log "$COLOR" "LEVEL" "message..."
    local colour="$1"
    local level="$2"
    shift 2
    printf '%b[%s]%b %s\n' "$colour" "$level" "$NC" "$*"
}

log_info() { _log "$GREEN" "INFO" "$@"; }
log_warn() { _log "$YELLOW" "WARN" "$@"; }
log_error() { _log "$RED" "ERROR" "$@"; }

die() {
    log_error "$@"
    exit 1
}

require_not_root() {
    if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
        die "This script should not be run as root"
    fi
}

require_command() {
    local cmd="$1"
    local default_hint="Install '$cmd' before running this script."
    local hint="${2:-$default_hint}"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        die "Required command '$cmd' not found. $hint"
    fi
}

run_step() {
    local description="$1"
    shift
    log_info "$description"
    "$@"
}


install_ruby() {
    log_info "Installing Ruby..."
    # mise use --global ruby@3.4.5 --verbose
    mise trust ~/.config/mise/config.toml
    mise install --verbose
    log_info "Ruby installed"
}

install_gh_copilot() {
    if ! command -v gh >/dev/null 2>&1; then
        log_warn "GitHub CLI not found; skipping gh-copilot installation"
        return 0
    fi

    if gh extension list 2>/dev/null | awk '{print $1}' | grep -Fxq "gh-copilot"; then
        log_info "gh-copilot extension already installed"
    else
        log_info "Installing gh-copilot extension..."
        if ! gh extension install github/gh-copilot; then
            log_warn "gh-copilot installation failed"
        fi
    fi
}

update_gh_copilot() {
    if ! command -v gh >/dev/null 2>&1; then
        log_warn "GitHub CLI not found; skipping gh-copilot update"
        return 0
    fi

    if gh extension list 2>/dev/null | awk '{print $1}' | grep -Fxq "gh-copilot"; then
        log_info "Updating gh-copilot extension..."
        if ! gh extension upgrade gh-copilot; then
            log_warn "gh-copilot upgrade failed"
        fi
    else
        log_warn "gh-copilot extension not installed; skipping update"
    fi
}

update_atuin() {
    if command -v atuin >/dev/null 2>&1; then
        log_info "Updating Atuin..."
        if ! atuin update; then
            log_warn "Atuin update failed"
        fi
    else
        log_warn "Atuin not found, skipping update"
    fi
}

install_atuin() {
    require_command "curl" "curl is required to bootstrap Atuin."

    if ! command -v atuin >/dev/null 2>&1; then
        log_info "Installing Atuin..."
        if ! curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh; then
            log_warn "Atuin installation failed"
        fi
    else
        log_info "Atuin already installed"
    fi
}

install_proxyman_components() {
    if [[ ! -d "/Applications/Proxyman.app" ]]; then
        log_warn "Proxyman not found, skipping privileged components installation"
        return 0
    fi

    local helper_path="/Library/PrivilegedHelperTools/com.proxyman.NSProxy.HelperTool"
    if [[ -e "$helper_path" ]]; then
        log_info "Proxyman privileged components already installed"
        return 0
    fi

    log_info "Installing Proxyman privileged components..."
    if ! sudo /Applications/Proxyman.app/Contents/MacOS/proxyman --install-privileged-components; then
        log_warn "Proxyman privileged components installation failed"
    fi
}
