#!/bin/bash
xcode-select --install

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# https://github.com/dsmelov/simsim/blob/master/Release/SimSim_latest.zip?raw=true
#https://github.com/x74353/Amphetamine-Enhancer
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_DISPLAY_INSTALL_TIMES=1

brew install whalebrew
brew install mas

brew bundle install

duti -s io.mpv avi all
duti -s io.mpv mkv all
duti -s io.mpv mp4 all
duti -s io.mpv mov all

open -a "Firefox" --args --make-default-browser


gem install xcpretty
gem install cocoapods
npm install -g apollo
npm install -g react-native
