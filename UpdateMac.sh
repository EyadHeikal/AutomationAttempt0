#!/bin/bash

sudo -v

#gem update --system
gem update

brew update
brew upgrade
brew upgrade --cask --greedy -f
brew outdated --cask --greedy --verbose

brew cleanup --prune=all

mas upgrade

# softwareupdate -i update-name // Mac update
softwareupdate -l // software update

# softwareupdate -i -a // Download and install all Mac updates
