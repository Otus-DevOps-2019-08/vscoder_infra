# Packer-related actions
PACKER_VERSION?=1.4.4
BIN_DIR?=~/bin
TEMP_DIR?=/tmp

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

terraform_stage_init:
	cd ./terraform/stage && ${BIN_DIR}/terraform init

terraform_stage_apply:
	cd ./terraform/stage && ${BIN_DIR}/terraform apply

terraform_stage_destroy:
	cd ./terraform/stage && ${BIN_DIR}/terraform destroy

terraform_stage_url:
	cd ./terraform/stage && ${BIN_DIR}/terraform output app_url	

terraform_prod_init:
	cd ./terraform/prod && ${BIN_DIR}/terraform init

terraform_prod_apply:
	cd ./terraform/prod && ${BIN_DIR}/terraform apply

terraform_prod_destroy:
	cd ./terraform/prod && ${BIN_DIR}/terraform destroy

terraform_prod_url:
	cd ./terraform/prod && ${BIN_DIR}/terraform output app_url	

ansible_inventory_list:
	cd ./ansible && ../.venv/bin/ansible-inventory --list

ansible_site_check:
	cd ./ansible && pwd && ../.venv/bin/ansible-playbook --diff site.yml --check

ansible_site_apply:
	echo "Press CTRL+C within 5 seconds to cancel playbook..." && \
	sleep 5 && \
	cd ./ansible && \
	../.venv/bin/ansible-playbook --diff site.yml


build: packer_build_db packer_build_app

infra_stage: terraform_stage_init terraform_stage_apply

infra_prod: terraform_prod_init terraform_prod_apply

site: ansible_site_check ansible_site_apply