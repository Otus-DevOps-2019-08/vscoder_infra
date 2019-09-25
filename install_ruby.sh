#!/bin/bash

###
# install_ruby.sh
# Installs latest ruby-full and ruby-bundler on Ubuntu 16.04
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

PKGS="ruby-full ruby-bundler build-essential"

echo "*** Start ruby and bundler installation..."

#
# Install
#
echo "*** Update apt cache"
sudo apt-get -qq update || { echo "ERROR: Can't add apt repository! Exiting."; exit 13; }

echo "*** Install package: $PKGS"
sudo apt-get install -y $PKGS || { echo "ERROR: Can't install package '$PKGS'! Exiting."; exit 14; }

#
# Check
#
ruby -v || { echo "ERROR: Can't check ruby version! Exiting."; exit 128; }
bundler -v || { echo "ERROR: Can't check bundler version! Exiting."; exit 129; }

echo "*** Complete. Ruby and bundler installed succefully."

