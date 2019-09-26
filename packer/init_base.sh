#!/bin/bash
###
# init_packer.sh
# Bake packer image ubuntu16.json and deploy instance from it
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

# Terminate on error or uninitialized variable. Debug.
set -eux
echo "***Bake backer-base image"

# Initialize variables
source .env

echo "*** Rebuild $PACKER_IMAGE_FILE"
packer validate -var-file=variables.json $PACKER_IMAGE_FILE
packer build -var-file=variables.json $PACKER_IMAGE_FILE
