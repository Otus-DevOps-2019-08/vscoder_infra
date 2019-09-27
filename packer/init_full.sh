#!/bin/bash
###
# init_full.sh
# Bake packer image immutable.json and deploy instance from it
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

# Terminate on error or uninitialized variable. Debug.
set -eux
echo "***Bake backer-base image"

# Initialize variables
PACKER_IMAGE_FILE=immutable.json

echo "*** Rebuild $PACKER_IMAGE_FILE"
packer validate -var-file=variables-immutable.json $PACKER_IMAGE_FILE
packer build -on-error=ask -var-file=variables-immutable.json $PACKER_IMAGE_FILE
