#!/bin/bash
set -e

###
# install_mongodb.sh
# Installs and start mongodb-org on Ubuntu 16.04
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

[[ $- == *i* ]] || export DEBIAN_FRONTEND="noninteractive"

PKGS="mongodb-org"
VER="3.2"
KEYURL="https://www.mongodb.org/static/pgp/server-3.2.asc"

echo "*** Start mongodb installation..."

#
# Install
#
echo "*** Get apt key"
wget -qO - $KEYURL | apt-key add - || { echo "ERROR: Can't get apt key from '$KEYURL'! Exiting."; exit 21; }

echo "*** Add mongodb reposityry"
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/$VER multiverse" | tee /etc/apt/sources.list.d/mongodb-org-${VER}.list || { echo "ERROR: Can't add apt repository! Exiting."; exit 22; }

echo "*** Update apt cache"
apt-get -qq update || { echo "ERROR: Can't add apt repository! Exiting."; exit 23; }

echo "*** Install package: $PKGS"
apt-get install -y $PKGS || { echo "ERROR: Can't install package '$PKGS'! Exiting."; exit 24; }

#
# Start and check
#
echo "*** Enable and run mongod.service"
systemctl start mongod || { echo "ERROR: Can't start mongod.service! Exiting."; exit 130; }
systemctl enable mongod || { echo "ERROR: Can't enable mongod.service! Exiting."; exit 131; }
systemctl --no-pager status mongod || { echo "ERROR: Service mongod is not running! Exiting."; exit 132; }

echo "*** Complete. Service mongod installed and running."
