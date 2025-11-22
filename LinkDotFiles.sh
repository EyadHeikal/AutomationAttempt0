#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

trap 'log_error "Linking dotfiles failed (line $LINENO)."; exit 1' ERR

timestamp() {
    date +"%Y%m%d-%H%M%S"
}

# Function to create symlink safely
create_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        log_warn "Source missing, skipping: $source"
        return
    fi

    mkdir -p "$(dirname "$target")"

    if [[ -L "$target" ]]; then
        local current_target
        current_target="$(readlink "$target")"
        if [[ "$current_target" == "$source" ]]; then
            log_info "Symlink already in place: $target"
            return
        fi
        log_info "Removing existing symlink: $target"
        rm "$target"
    elif [[ -e "$target" ]]; then
        local backup
        backup="${target}.backup.$(timestamp)"
        log_warn "Backing up existing path: $target -> $backup"
        mv "$target" "$backup"
    fi

    log_info "Creating symlink: $target -> $source"
    ln -s "$source" "$target"
}

declare -a LINK_TARGETS=(
    "dotfiles/bashrc:$HOME/.bashrc"
    "dotfiles/zshrc:$HOME/.zshrc"
    "dotfiles/bash_aliases:$HOME/.bash_aliases"
    "dotfiles/gitconfig:$HOME/.gitconfig"
    "dotfiles/gitignore:$HOME/.gitignore_global"
    "dotfiles/finicky.js:$HOME/.finicky.js"
    "dotfiles/hammerspoon:$HOME/.hammerspoon"
    "dotfiles/codex.toml:$HOME/.codex/config.toml"
    "dotfiles/mise.toml:$HOME/.config/mise/config.toml"
    "dotfiles/com.1password.1password.json:$HOME/Library/Application Support/Chromium/NativeMessagingHosts/com.1password.1password.json"
)

log_info "Linking configuration files..."

for mapping in "${LINK_TARGETS[@]}"; do
    source_path="${mapping%%:*}"
    target_path="${mapping#*:}"
    create_symlink "$SCRIPT_DIR/$source_path" "$target_path"
done

trap - ERR
log_info "Configuration files linked successfully!"
log_info "Restart your shell or run 'source ~/.zshrc' (or ~/.bashrc) to apply changes"
