# Homebrew setup
eval "$(/opt/homebrew/bin/brew shellenv)"

# Ruby version manager (chruby)
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.2.2

# PATH additions
export PATH=$HOME/Public/Projects/flutter/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="/Users/eyad/.codeium/windsurf/bin:$PATH"

# Atuin shell history setup
if [ -f "$HOME/.atuin/bin/env" ]; then
    . "$HOME/.atuin/bin/env"
    
    # Shell-specific Atuin initialization
    if [ -n "$BASH_VERSION" ]; then
        # Bash-specific setup
        [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
        if command -v atuin >/dev/null 2>&1; then
            eval "$(atuin init bash)"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        # Zsh-specific setup
        if command -v atuin >/dev/null 2>&1; then
            eval "$(atuin init zsh)"
        fi
    fi
fi