#!/bin/bash
###
# init_full.sh
# Bake packer image immutable.json and deploy instance from it
# author: Aleksey Koloskov <vsyscoder@gmail.com>
###

# Terminate on error or uninitialized variable. Debug.
set -eux
echo "***Bake backer image"

BASEDIR=$(dirname "$0")
cd $BASEDIR

# Initialize variables
VARIABLES_FILE=variables.json
PACKER_IMAGE_FILE=$1

echo "*** Rebuild $PACKER_IMAGE_FILE"
packer validate -var-file=$VARIABLES_FILE $PACKER_IMAGE_FILE
packer build -on-error=ask -var-file=$VARIABLES_FILE $PACKER_IMAGE_FILE

cd -
