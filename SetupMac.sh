#!/bin/bash

set -e
set -o pipefail

#xcode-select --install

#sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# https://github.com/dsmelov/simsim/blob/master/Release/SimSim_latest.zip?raw=true
# https://github.com/x74353/Amphetamine-Enhancer
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
export NONINTERACTIVE=1

#brew install whalebrew mas

brew bundle install

#gh extension install github/gh-copilot

duti -s io.mpv avi all
duti -s io.mpv mkv all
duti -s io.mpv mp4 all
duti -s io.mpv mov all
duti -s io.mpv mp3 all

#open -a "Firefox" --args --make-default-browser

#gem install xcpretty
#gem install cocoapods
#gem install bundler
npm install -g apollo
npm install -g react-native


curl -fsSL https://pkgs.netbird.io/install.sh | sh
netbird up --management-url https://netbird-mgmt.instabug.tools:33073
