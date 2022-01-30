#!/bin/sh

sudo dnf -y groupinstall "`cat load-groupinstall.txt`"
sudo dnf install `cat load-install.txt`
