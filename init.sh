#!/bin/bash

# default-puma-server
# puma-server

###
# init.sh
# Create vm instance Ubuntu 16.04 on GCP
# and deploy puma-server on it
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

VM_NAME=reddit-app
VM_TAGS=puma-server
STARTUP_SCRIPT=startup.sh

# Generate startup script
cat install_ruby.sh install_mongodb.sh deploy.sh > $STARTUP_SCRIPT

# Create VM
gcloud compute instances create $VM_NAME\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags $VM_TAGS \
  --restart-on-failure \
  --metadata-from-file startup-script=$STARTUP_SCRIPT
