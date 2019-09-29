#!/bin/bash

###
# create-reddit-vm.sh
# Deploy VM on GCE from reddit-full image
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

set -eux

# Initialize variables
VM_NAME=reddit-full
IMAGE_FAMILY=reddit-full
VM_TAGS=puma-server
FW_RULE=default-puma-server
APP_PORT=9292

# Create temporary working directory
TEMPWD=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")

echo "*** Check instance '$VM_NAME' exists"
RC=0
gcloud compute instances describe $VM_NAME > $TEMPWD/vmdescr.yml 2>/dev/null || { RC=1; true; }

# If instance not exists, create it
if [ $RC -ne 0 ]
then
  # Create VM
  echo "*** Create VM $VM_NAME from image $IMAGE_FAMILY"
  gcloud compute instances create $VM_NAME\
    --image-family $IMAGE_FAMILY \
    --tags "$VM_TAGS" \
    --restart-on-failure

  gcloud compute instances describe $VM_NAME > $TEMPWD/vmdescr.yml
fi

# Get VM's external ip
WAN_IP="$(cat $TEMPWD/vmdescr.yml | grep 'natIP: ' | awk '{ print $2; }')"
echo "VM external IP is $WAN_IP"

# Remove temp file and dir
rm $TEMPWD/vmdescr.yml
rm -r $TEMPWD

# Create firewall rule
echo "*** Create firewall rule, if not exists"
gcloud compute firewall-rules describe $FW_RULE &>/dev/null || gcloud compute firewall-rules create $FW_RULE \
  --allow=tcp:$APP_PORT \
  --target-tags="$VM_TAGS"

echo "Completed. Service will be accessible soon at http://$WAN_IP:$APP_PORT"

# TODO: rediness-probe via curl
