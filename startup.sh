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

#!/bin/bash

###
# install_mongodb.sh
# Installs and start mongodb-org on Ubuntu 16.04
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

PKGS="mongodb-org"
VER="3.2"
KEYURL="https://www.mongodb.org/static/pgp/server-3.2.asc"

echo "*** Start mongodb installation..."

#
# Install
#
echo "*** Get apt key"
wget -qO - $KEYURL | sudo apt-key add - || { echo "ERROR: Can't get apt key from '$KEYURL'! Exiting."; exit 21; }

echo "*** Add mongodb reposityry"
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/$VER multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-${VER}.list || { echo "ERROR: Can't add apt repository! Exiting."; exit 22; }

echo "*** Update apt cache"
sudo apt-get -qq update || { echo "ERROR: Can't add apt repository! Exiting."; exit 23; }

echo "*** Install package: $PKGS"
sudo apt-get install -y $PKGS || { echo "ERROR: Can't install package '$PKGS'! Exiting."; exit 24; }

#
# Start and check
#
echo "*** Enable and run mongod.service"
sudo systemctl start mongod || { echo "ERROR: Can't start mongod.service! Exiting."; exit 130; }
sudo systemctl enable mongod || { echo "ERROR: Can't enable mongod.service! Exiting."; exit 131; }
sudo systemctl --no-pager status mongod || { echo "ERROR: Service mongod is not running! Exiting."; exit 132; }

echo "*** Complete. Service mongod installed and running."

#!/bin/bash

###
# deploy.sh
# Installs and start puma-server on Ubuntu 16.04
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

DEPLOY_ROOT=/home/appuser
PUMA_GIT_URI=https://github.com/express42/reddit.git
PUMA_BRANCH=monolith
DEST_DIR=reddit

echo "*** Start puma server deploy"

#
# Install
#
echo "*** Clone puma repo from $PUMA_GIT_URI to $DEPLOY_ROOT/reddit"
test -d $DEPLOY_ROOT || { echo "ERROR: '$DEPLOY_ROOT' not exists or not a directory! Exiting."; exit 31; }
cd $DEPLOY_ROOT
git clone -b $PUMA_BRANCH $PUMA_GIT_URI $DEPLOY_ROOT/$DEST_DIR || { echo "ERROR: Can't clone $PUMA_GIT_URI to '$DEPLOY_ROOT/$DEST_DIR'! Exiting."; exit 32; }

echo "*** Install gems"
cd $DEPLOY_ROOT/$DEST_DIR
bundle install || { echo "ERROR: Can't install gems! Exiting."; exit 33; }

#
# Run and check
#
# TODO: Run puma server as systemd service
puma -d || { echo "ERROR: Can't start puma-server! Exiting."; exit 34; }
ps aux | grep puma || { echo "ERROR: Puma server is not running! Exiting."; exit 133; }

echo "*** Complete. Puma daemon is running."

