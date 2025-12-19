#!/usr/bin/env bash
set -euo pipefail

# 1) Download prebuilt xcodes binary
XCODE_VERSION="26.2"
TMPDIR="$(mktemp -d)"
cd "$TMPDIR"

curl -L "https://github.com/XcodesOrg/xcodes/releases/latest/download/xcodes.zip" -o xcodes.zip
unzip xcodes.zip

# There should now be an `xcodes` binary here
chmod +x xcodes

# 2) Sanity check: run it directly from here
./xcodes --help || {
  echo "xcodes failed to run"
  exit 1
}

# 3) Use xcodes to install Xcode
# First run will ask for Apple ID and store it in Keychain
./xcodes update
./xcodes install "$XCODE_VERSION"   # or whatever version you want

sudo rm -rf /Library/Developer/CommandLineTools

sudo xcode-select -r

# xcode-select -p
# sudo xcode-select -switch /Applications/Xcode-26.2.0.app
# sudo xcode-select -switch /Applications/Xcode-26.2.0.app/Contents/Developer
# # 4) Make that Xcode the active one
./xcodes select "$XCODE_VERSION"

# 5) Run Xcode first-launch setup (now that it actually exists)
xcodebuild -runFirstLaunch

# 6) Accept license agreement
sudo xcodebuild -license accept

# 7) Install iOS Simulator and other platforms
# Download and install iOS platform (includes iOS simulators)
# Note: xcodebuild -downloadPlatform both downloads AND installs the platform
xcodebuild -downloadPlatform iOS

# 8) Cleanup
cd /
rm -rf "$TMPDIR"