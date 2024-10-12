#!/bin/bash

# sudo -v

# gem update --system
gem update

brew update

brew outdated
brew upgrade
# brew outdated --greedy
# brew upgrade --greedy -f

brew outdated --casks
brew upgrade --cask
# brew outdated --casks --greedy
# brew upgrade --cask --greedy -f


brew cleanup --prune=all


mas outdated
# mas upgrade &

softwareupdate -l // software update
# softwareupdate -i update-name // Mac update
# softwareupdate -i -a // Download and install all Mac updates
