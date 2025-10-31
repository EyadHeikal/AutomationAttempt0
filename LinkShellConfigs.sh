#!/bin/bash

# Strict error handling
set -e
set -o pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

# Function to create symlink safely
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ]; then
        log_info "Removing existing symlink: $target"
        rm "$target"
    elif [ -f "$target" ]; then
        log_warn "Backing up existing file: $target to ${target}.backup"
        mv "$target" "${target}.backup"
    fi
    
    log_info "Creating symlink: $target -> $source"
    ln -s "$source" "$target"
}

# Create symlinks for shell configuration files
log_info "Linking shell configuration files..."

create_symlink "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc"
create_symlink "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

log_info "Shell configuration files linked successfully!"
log_info "Restart your shell or run 'source ~/.zshrc' (or ~/.bashrc) to apply changes"

