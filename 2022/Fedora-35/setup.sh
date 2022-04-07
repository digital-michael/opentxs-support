#!/bin/sh

#dev env setup
cat load-groupinstall.txt | xargs sudo dnf -y groupinstall
cat load-install.txt | xargs sudo dnf -y install

# otscripts
cd ~
git clone git@github.com:matterfi/otscripts.git
cd otscripts
./init
echo reference local setup for fedora KDE 35 in .env-fedora-kde-35

# set now so we can run
OT_SCRIPT_PARENT=${HOME}
PATH=${OT_SCRIPT_PARENT}/otscripts/:${PATH}

# add to ~/localrc to enable running later
echo OT_SCRIPT_PARENT=${HOME} >> ${HOME}/localrc
echo PATH=${OT_SCRIPT_PARENT}/otscripts/:${PATH} >> ${HOME/localrc

# setup for flatpak builds
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub org.kde.Platform//5.15
sudo flatpak install flathub org.kde.Sdk//5.15
mkdir ~/build/metier-flatpak/

echo execute: rebuild_opentxs full gcc
echo execute: rebuild_metier gcc
echo execute: flatpak-builder ~/build/metier-flatpak/ ~/src/metier/package/gui.flatpak.json

