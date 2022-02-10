#!/bin/sh

#dev env setup
cat load-groupinstall.txt | xargs sudo dnf -y groupinstall
cat load-install.txt | xargs sudo dnf -y install

# otscripts
cd ~
git clone git@github.com:matterfi/otscripts.git
cd otscripts
./init
# reference local setup for fedora KDE 35 in .env-fedora-kde-35

