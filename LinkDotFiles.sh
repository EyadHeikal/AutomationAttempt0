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
    "dotfiles/profile:$HOME/.profile"
    "dotfiles/zprofile:$HOME/.zprofile"
    "dotfiles/bash_aliases:$HOME/.bash_aliases"
    "dotfiles/gitconfig:$HOME/.gitconfig"
    "dotfiles/gitignore:$HOME/.gitignore_global"
    "dotfiles/finicky.js:$HOME/.finicky.js"
    "dotfiles/hammerspoon:$HOME/.hammerspoon"
    "dotfiles/notmise.toml:$HOME/.config/mise/config.toml"
    "dotfiles/bundler:$HOME/.bundle/config"
    "dotfiles/ssh:$HOME/.ssh/config"
    "dotfiles/com.1password.1password.json:$HOME/Library/Application Support/Chromium/NativeMessagingHosts/com.1password.1password.json"
    "dotfiles/ai/codex/config.toml:$HOME/.codex/config.toml"
    "dotfiles/ai/claude/settings.json:$HOME/.claude/settings.json"
    "dotfiles/ai/context.md:$HOME/.codex/AGENTS.md"
    "dotfiles/ai/context.md:$HOME/.claude/CLAUDE.md"
    "dotfiles/ai/context.md:$HOME/.github/copilot-instructions.md"
    "dotfiles/ai/rules:$HOME/.claude/rules"
    "dotfiles/ai/rules:$HOME/.cursor/rules"
    "dotfiles/ai/rules:$HOME/.github/instructions"
    "dotfiles/ai/humanlayer/codelayer.json:$HOME/.humanlayer/codelayer.json"
    "dotfiles/ai/humanlayer/database.db:$HOME/.humanlayer/daemon.db"
    "dotfiles/ai/humanlayer/database.db-shm:$HOME/.humanlayer/daemon.db-shm"
    "dotfiles/ai/humanlayer/database.db-wal:$HOME/.humanlayer/daemon.db-wal"
    "dotfiles/ai/humanlayer/database.db:$HOME/.humanlayer/daemon-pro.db"
    "dotfiles/ai/humanlayer/database.db-shm:$HOME/.humanlayer/daemon-pro.db-shm"
    "dotfiles/ai/humanlayer/database.db-wal:$HOME/.humanlayer/daemon-pro.db-wal"
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
