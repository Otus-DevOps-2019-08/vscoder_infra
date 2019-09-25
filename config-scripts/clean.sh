#!/bin/bash

###
# clean.sh
# Remove created objects from GCP
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

source .env

gcloud compute instances delete $VM_NAME
gsutil -m rm -r $BUCKET
gcloud compute firewall-rules delete $FW_RULE
