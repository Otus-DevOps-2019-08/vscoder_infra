#!/bin/bash

###
# deploy.sh
# Installs and start puma-server on Ubuntu 16.04
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

set -eux

DEPLOY_ROOT=/home/appuser
PUMA_GIT_URI=https://github.com/express42/reddit.git
PUMA_BRANCH=monolith
DEST_DIR=reddit
SERVICE_NAME=reddit-app
APPUSER=appuser
PIDFILE=$DEPLOY_ROOT/$DEST_DIR/${SERVICE_NAME}.pid

echo "*** Start puma server deploy as $(whoami)"

#
# Install
#
echo "*** Clone puma repo from $PUMA_GIT_URI to $DEPLOY_ROOT/reddit"
test -d $DEPLOY_ROOT
cd $DEPLOY_ROOT
sudo -u $APPUSER git clone -b $PUMA_BRANCH $PUMA_GIT_URI $DEPLOY_ROOT/$DEST_DIR

echo "*** Install gems"
cd $DEPLOY_ROOT/$DEST_DIR
sudo -u $APPUSER bundle install

#
# Ensure puma executable propertly installed
#
sudo -u $APPUSER which puma
sudo -u $APPUSER puma --version

echo "*** Provide ${SERVICE_NAME}.service for systemd"
cat <<EOF > ${SERVICE_NAME}.service
[Unit]
Description=Puma HTTP Forking Server with reddit-app
After=network.target

[Service]
Type=forking
User=${APPUSER}
WorkingDirectory=$DEPLOY_ROOT/$DEST_DIR
ExecStart=/usr/local/bin/puma --pidfile $PIDFILE --daemon
ExecStop=/usr/local/bin/pumactl --pidfile $PIDFILE stop
PIDFile=${PIDFILE}
Restart=on-failure
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF
mv ${SERVICE_NAME}.service /etc/systemd/system/

# Enable service
systemctl daemon-reload
systemctl enable ${SERVICE_NAME}.service

echo "*** Check ${SERVICE_NAME} service installation"
systemctl start ${SERVICE_NAME}.service
systemctl status ${SERVICE_NAME}.service
systemctl restart ${SERVICE_NAME}.service
systemctl status ${SERVICE_NAME}.service
systemctl stop ${SERVICE_NAME}.service
# If nothing happend here (because of `set -e`), all is okay.

echo "*** Complete. Puma daemon is installed."
