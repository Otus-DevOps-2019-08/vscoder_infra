#!/bin/bash
set -eux

echo "*** Set environment variables ***"
export APP_DIR=${HOME}/reddit

echo "*** Install app to '$APP_DIR' ***"
git clone -b monolith https://github.com/express42/reddit.git $APP_DIR
cd $APP_DIR
bundle install

echo "*** Provide environment variables file '$APP_DIR/puma.env' ***"
sudo mv /tmp/puma.env $APP_DIR/puma.env

echo "*** Provide puma systemd service from template ***"
cat /tmp/puma.service.tmpl | envsubst | sudo tee /etc/systemd/system/puma.service
sudo systemctl start puma
sudo systemctl enable puma
