#!/bin/bash

sudo gem update --system

brew update
brew upgrade
brew upgrade --cask --greedy
brew outdated --cask --greedy --verbose

mas upgrade

# softwareupdate -i update-name // Mac update
softwareupdate -l // software update

# softwareupdate -i -a // Download and install all Mac updates
