#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

trap 'log_error "Clearing derived data failed (line $LINENO)."; exit 1' ERR

# Clear Xcode derived data using fastlane
# This script attempts to use local bundle exec first, then falls back to global fastlane

log_info "Current directory: $(pwd)"

if command -v bundle >/dev/null 2>&1 && bundle show fastlane >/dev/null 2>&1; then
    log_info "Using bundled Fastlane..."
    if bundle exec fastlane run clear_derived_data; then
        log_info "Derived data cleared successfully"
        trap - ERR
        exit 0
    fi
fi

if command -v fastlane >/dev/null 2>&1; then
    log_info "Using global Fastlane..."
    if fastlane run clear_derived_data; then
        log_info "Derived data cleared successfully"
        trap - ERR
        exit 0
    fi
fi

die "Fastlane not found. Install with: gem install fastlane"
