#!/bin/sh

echo DO NOT RUN THIS YET! NOT READY!
echo JUST NOTES!

exit 0

# SETUP SSH
## REF: https://knowledge.autodesk.com/support/smoke/troubleshooting/caas/sfdcarticles/sfdcarticles/Enabling-remote-SSH-login-on-Mac-OS-X.html

ssh localhost # establish ~/.ssh directory

#copy ed25519 into ~/.ssh
#copy/configure ~/.ssh/config
#chmdor 600 ~/.ssh/ed25519 keyfile

# SETUP BREW
## https://brew.sh/

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# CONFIGURE BREW
## DISABLE ANALYTICS
## REF:   https://docs.brew.sh/Analytics
export HOMEBREW_NO_ANALYTICS=1
brew analytics off

## put on path
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"


# BREW INSTALL
brew tap homebrew/cask-versions
brew install firefox
brew install --cask cmake
brew install xcodeclangformat
brew install vcpkg
brew install --cask visual-studio

# SETUP WORK
cd ~
mkdir ~/src
cd ~/src
set ID="digital-michael"
git clone --recursive git@github.com:$ID/wallet.git                                                       
git clone --recursive git@github.com:$ID/otscripts.git                                                    │
git clone --recursive git@github.com:$ID/opentxs.git  

# SETUP OTSCRIPTS
export OT_SCRIPT_PARENT=~/src/
PATH=${PATH}:${OT_SCRIPT_PARENT}/otscripts/
cd otscripts
./init
# Edit file local



