#!/usr/bin/env bash
set -euo pipefail

# 1) Download prebuilt xcodes binary
XCODE_VERSION="26.1.1"
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
./xcodes install $XCODE_VERSION   # or whatever version you want

# # 4) Make that Xcode the active one
./xcodes select $XCODE_VERSION

# 5) Accept Xcode license
# xcodebuild -license accept

# 5) Run Xcode first-launch setup (now that it actually exists)
xcodebuild -runFirstLaunch

# 6) Download iOS platform
# start another process to download the iOS platform (will continue after script exits)
# nohup xcodebuild -downloadPlatform iOS > /dev/null 2>&1 &
# xcodebuild -downloadPlatform iOS > /dev/null 2>&1 &
# disown %1


# 7) Cleanup
cd /
rm -rf "$TMPDIR"
