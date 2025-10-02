#!/bin/bash

brew update

# brew outdated
# brew upgrade
brew outdated --greedy
brew upgrade --greedy -f

# brew outdated --casks
# brew upgrade --cask
brew outdated --casks --greedy
brew upgrade --cask --greedy -f


brew cleanup --prune=all

gh extension upgrade gh-copilot

mas outdated
# mas upgrade &

softwareupdate -l // software update
# softwareupdate -i update-name // Mac update
# softwareupdate -i -a // Download and install all Mac updates
