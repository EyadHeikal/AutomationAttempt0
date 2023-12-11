#!/bin/bash

sudo gem update --system

brew update
brew upgrade
brew upgrade --cask --greedy -f
brew outdated --cask --greedy --verbose

brew cleanup --prune=all

mas upgrade

# softwareupdate -i update-name // Mac update
softwareupdate -l // software update

# softwareupdate -i -a // Download and install all Mac updates
