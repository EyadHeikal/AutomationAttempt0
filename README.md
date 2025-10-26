# Mac Setup Scripts

Collection of scripts for setting up and maintaining a macOS development environment.

## 📋 Scripts

### SetupMac.sh
Initial Mac setup script that installs and configures system-level development tools.

**Features:**
- Installs Xcode Command Line Tools
- Installs Homebrew (with Apple Silicon support)
- Installs packages from Brewfile
- Configures file associations for MPV
- Installs npm packages (@anthropic-ai/claude-code)
- Installs and configures NetBird VPN
- Installs Cursor editor
- Installs Proxyman privileged components
- Includes error handling and colored logging

**Usage:**
```bash
./SetupMac.sh
```

### SetupMacUser.sh
User-level setup script that installs user-specific tools without system privileges.

**Features:**
- Installs Atuin (shell history tool)
- Auto-configures shell integration
- No sudo required

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
- Checks for Mac App Store updates
- Checks for macOS system updates
- Asks for confirmation before upgrading
- Includes colored logging

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

## 🚀 Quick Start

1. Clone this repository
2. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```
3. Run the setup scripts:
   ```bash
   ./SetupMac.sh      # System-level setup (requires sudo)
   ./SetupMacUser.sh  # User-level setup (no sudo required)
   ```

## 📦 Using Makefile

For convenience, you can use the Makefile:

```bash
# System-level setup
make setup

# User-level setup
make setup-user

# Update system packages
make update

# Update user-level tools
make update-user

# Clear Xcode derived data
make clean-xcode

# Run all setup tasks
make all
```

## 🔧 Configuration

### Brewfile
The `Brewfile` contains all Homebrew packages, casks, and Mac App Store apps to be installed. Edit this file to customize your installation.

### NetBird Configuration
By default, the setup script connects to `https://netbird-mgmt.instabug.tools:33073`. Modify `SetupMac.sh` if you need a different management URL.

## 📝 Notes

- All scripts include error handling with `set -e` and `set -o pipefail`
- Scripts should not be run as root
- Colored output helps identify info, warnings, and errors
- Scripts check for existing installations before attempting to install

## 🛠️ Requirements

- macOS (tested on macOS 15.x)
- Internet connection
- Administrator privileges (for some installations)

## 📄 License

These scripts are provided as-is for personal use.
