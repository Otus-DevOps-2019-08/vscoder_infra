PACKER_VERSION?=1.4.4
BIN_DIR?=~/bin
TEMP_DIR?=/tmp
# Environment name
ENV?=stage
# inventory file name inside environment
INV?=inventory.gcp.yml

PACKER_URL=https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip

# .PHONY: debug

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
	${BIN_DIR}/packer --version && rm ${TEMP_DIR}/packer-${PACKER_VERSION}.zip

install_ansible:
	test -d .venv || python3 -m venv .venv
	./.venv/bin/pip install -r ansible/requirements.txt

# TODO:
# install_terraform:

packer_build_db:
	${BIN_DIR}/packer build -var-file=packer/variables.json packer/db.json

packer_build_app:
	${BIN_DIR}/packer build -var-file=packer/variables.json packer/app.json

terraform_init:
	cd ./terraform/${ENV} && ${BIN_DIR}/terraform init

terraform_apply:
	cd ./terraform/${ENV} && ${BIN_DIR}/terraform apply

terraform_destroy:
	cd ./terraform/${ENV} && ${BIN_DIR}/terraform destroy

terraform_url:
	cd ./terraform/${ENV} && ${BIN_DIR}/terraform output app_url	

ansible_inventory_list:
	cd ./ansible && ../.venv/bin/ansible-inventory -i environments/${ENV}/${INV} --list

ansible_site_check:
	cd ./ansible && pwd && ../.venv/bin/ansible-playbook -i environments/${ENV}/${INV} --diff site.yml --check

ansible_site_apply:
	echo "Press CTRL+C within 5 seconds to cancel playbook..." && \
	sleep 5 && \
	cd ./ansible && \
	../.venv/bin/ansible-playbook -i environments/${ENV}/${INV} --diff site.yml


build: packer_build_db packer_build_app

infra: terraform_init terraform_apply

site: ansible_site_check ansible_site_apply
