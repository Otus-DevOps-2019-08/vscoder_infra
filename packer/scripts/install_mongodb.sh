#!/bin/bash
set -eux

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
wget -qO - $KEYURL | apt-key add -

echo "*** Add mongodb reposityry"
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/$VER multiverse" | tee /etc/apt/sources.list.d/mongodb-org-${VER}.list

echo "*** Update apt cache"
apt-get -qq update

echo "*** Install package: $PKGS"
apt-get install -y $PKGS

# echo "*** Configure mongod to listen on ip 0.0.0.0"
# sed -i.bak 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
# cat /etc/mongod.conf

#
# Start and check
#
echo "*** Enable mongod.service"
systemctl enable mongod

echo "*** Complete. Service mongod installed and running."
