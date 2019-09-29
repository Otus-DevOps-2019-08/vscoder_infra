#!/bin/bash
set -eux

###
# install_ruby.sh
# Installs latest ruby-full and ruby-bundler on Ubuntu 16.04
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

[[ $- == *i* ]] || export DEBIAN_FRONTEND="noninteractive"

PKGS="ruby-full ruby-bundler build-essential"

echo "*** Start ruby and bundler installation..."

#
# Install
#
echo "*** Update apt cache"
apt-get -qq update

echo "*** Install package: $PKGS"
apt-get install -y $PKGS

#
# Check
#
ruby -v
bundler -v

echo "*** Complete. Ruby and bundler installed succefully."
