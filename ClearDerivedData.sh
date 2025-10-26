#!/bin/bash

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Clear Xcode derived data using fastlane
# This script attempts to use local bundle exec first, then falls back to global fastlane

log_info "Current directory: $(pwd)"

if command -v bundle &>/dev/null && bundle show fastlane &>/dev/null; then
    log_info "Using bundled Fastlane..."
    if bundle exec fastlane run clear_derived_data; then
        log_info "Derived data cleared successfully"
        exit 0
    fi
fi

if command -v fastlane &>/dev/null; then
    log_info "Using global Fastlane..."
    if fastlane run clear_derived_data; then
        log_info "Derived data cleared successfully"
        exit 0
    fi
fi

log_error "Fastlane not found. Install with: gem install fastlane"
exit 1
