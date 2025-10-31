# Get the directory where this script is located (following symlinks)
SCRIPT_FILE="${(%):-%x}"
if [ -L "$SCRIPT_FILE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$(readlink "$SCRIPT_FILE")")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_FILE")" && pwd)"
fi

# Source common aliases and configurations
if [ -f "$SCRIPT_DIR/.bash_aliases" ]; then
    . "$SCRIPT_DIR/.bash_aliases"
else
    echo "Warning: $SCRIPT_DIR/.bash_aliases not found" >&2
fi
