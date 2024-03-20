#!/bin/bash

# sudo -v

# gem update --system
gem update

brew update
brew upgrade --greedy -f
brew upgrade --cask --greedy -f
brew outdated --cask --greedy --verbose

brew cleanup --prune=all

mas upgrade &

softwareupdate -l // software update
# softwareupdate -i update-name // Mac update
# softwareupdate -i -a // Download and install all Mac updates
