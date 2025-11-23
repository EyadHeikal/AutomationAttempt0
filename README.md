# Mac Setup Scripts

Collection of scripts for setting up and maintaining a macOS development environment.

## 📋 Scripts

### SetupMac.sh
Initial Mac setup script that installs and configures system-level development tools.

**Features:**
- Installs Xcode Command Line Tools
- Installs Homebrew (with Apple Silicon support)
- Installs packages from the repo `Brewfile` regardless of the invocation directory
- Configures file associations for MPV
- Installs npm packages (@kilocode/cli)
- Installs and configures NetBird VPN
- Installs Cursor editor
- Installs Proxyman privileged components
- Adds prerequisite checks (non-root, curl, Xcode CLI) and consistent error trapping

**Usage:**
```bash
./SetupMac.sh
```

### SetupMacUser.sh
User-level setup script that installs user-specific tools without system privileges.

**Features:**
- Installs Atuin (shell history tool)
- Installs Ruby via mise when available (skips gracefully otherwise)
- Links dotfiles (shell configs, `.bash_aliases`, gitconfig) with timestamped backups
- Auto-configures shell integration without clobbering existing files
- No sudo required
- Gracefully aborts if accidentally invoked as root

**Usage:**
```bash
./SetupMacUser.sh
```

### UpdateMac.sh
Updates all system-level packages and checks for system updates.

**Features:**
- Updates Homebrew and all packages
- Updates casks with greedy versioning
- Updates GitHub Copilot extension
- Reinstalls Proxyman privileged components
- Checks for Mac App Store updates when `mas` is available
- Checks for macOS system updates
- Asks for confirmation before upgrading
- Includes colored logging and clear warnings when optional steps fail

**Usage:**
```bash
./UpdateMac.sh
```

### UpdateMacUser.sh
Updates all user-level tools.

**Features:**
- Updates Atuin
- No sudo required

**Usage:**
```bash
./UpdateMacUser.sh
```

### ClearDerivedData.sh
Clears Xcode derived data using Fastlane.

**Features:**
- Attempts to use bundled Fastlane first
- Falls back to global Fastlane installation
- Provides clear error messages

**Usage:**
```bash
./ClearDerivedData.sh
```

### LinkDotFiles.sh
Creates symlinks for dotfiles and configuration files from this repository to your home directory.

**Features:**
- Links shell configuration files (`.bashrc`, `.zshrc`, `.bash_aliases`)
- Links `.gitconfig` for Git configuration
- Backs up existing paths with timestamped copies before linking
- Detects already-correct symlinks to avoid unnecessary churn
- Safe handling of missing sources and existing symlinks

**Usage:**
```bash
./LinkDotFiles.sh
```

## 🚀 Quick Start

1. Clone this repository
2. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```
3. Run the setup scripts:
   ```bash
   ./SetupMac.sh      # System-level setup
   ./SetupMacUser.sh  # User-level setup (no sudo required)
   ```

> The Makefile wrapper has been removed; run the shell scripts directly.

## 🔧 Configuration

### Brewfile
The `Brewfile` contains all Homebrew packages, casks, and Mac App Store apps to be installed. Edit this file to customize your installation.

### Configuration Files
This repository manages your dotfiles and configuration:

**Shell Configuration:**
- `.bashrc` - Bash shell configuration (minimal, sources `.bash_aliases`)
- `.zshrc` - Zsh shell configuration (minimal, sources `.bash_aliases`)
- `.bash_aliases` - Common shell configuration (Homebrew, Ruby, PATH, Atuin) with guards for missing dependencies

**Git Configuration:**
- `.gitconfig` - Git global configuration (user info, GPG signing, editor, rerere, rebase settings)

All configuration files are symlinked to your home directory, allowing you to version control your configurations and sync them across machines.

### NetBird Configuration
By default, the setup script connects to `https://netbird-mgmt.instabug.tools:33073`. Modify `SetupMac.sh` if you need a different management URL.

## 📝 Notes

- All scripts include strict error handling with `set -euo pipefail` and contextual `ERR` traps
- Scripts should not be run as root
- Colored output helps identify info, warnings, and errors
- Scripts check for existing installations before attempting to install

## 🛠️ Requirements

- macOS (tested on macOS 15.x)
- Internet connection
- Administrator privileges (for some installations)

## 📄 License

These scripts are provided as-is for personal use.
