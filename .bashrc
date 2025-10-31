# Get the directory where this script is located (following symlinks)
if [ -L "${BASH_SOURCE[0]}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$(readlink "${BASH_SOURCE[0]}")")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Source common aliases and configurations
if [ -f "$SCRIPT_DIR/.bash_aliases" ]; then
    . "$SCRIPT_DIR/.bash_aliases"
else
    echo "Warning: $SCRIPT_DIR/.bash_aliases not found" >&2
fi
