# Packer-related actions
PACKER_VERSION?=1.4.4
BIN_DIR?=~/bin
TEMP_DIR?=/tmp

PACKER_URL=https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip

.PHONY: debug install_packer

debug:
	echo PACKER_VERSION=${PACKER_VERSION}
	echo BIN_DIR=${BIN_DIR}
	echo TEMP_DIR=${TEMP_DIR}
	echo PACKER_URL=${PACKER_URL}

install_packer:
	wget ${PACKER_URL} -O ${TEMP_DIR}/packer-${PACKER_VERSION}.zip
	unzip -o ${TEMP_DIR}/packer-${PACKER_VERSION}.zip -d ${TEMP_DIR}/
	mv ${TEMP_DIR}/packer ${BIN_DIR}/packer-${PACKER_VERSION}
	ln -sf packer-${PACKER_VERSION} ${BIN_DIR}/packer
	${BIN_DIR}/packer --version

install_ansible:
	test -d .venv || python3 -m venv .venv
	./.venv/bin/pip install ansible

packer_build_db:
	${BIN_DIR}/packer build -var-file=packer/variables.json packer/db.json
