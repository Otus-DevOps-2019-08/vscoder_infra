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

