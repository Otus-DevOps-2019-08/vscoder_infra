BIN_DIR?=~/bin
TEMP_DIR?=/tmp
# Environment name
ENV?=stage
# inventory file name inside environment
INV?=inventory.gcp.yml

# Packer-related variables
PACKER_VERSION?=1.4.4
PACKER_URL=https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip

# Terraform-related variables
TERRAFORM_VERSION?=0.12.12
TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
TFLINT_VERSION?=0.12.1
TFLINT_URL=https://github.com/wata727/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip

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

install_terraform:
	wget ${TERRAFORM_URL} -O ${TEMP_DIR}/terraform-${TERRAFORM_VERSION}.zip
	unzip -o ${TEMP_DIR}/terraform-${TERRAFORM_VERSION}.zip -d ${TEMP_DIR}/
	mv ${TEMP_DIR}/terraform ${BIN_DIR}/terraform-${TERRAFORM_VERSION}
	ln -sf terraform-${TERRAFORM_VERSION} ${BIN_DIR}/terraform
	${BIN_DIR}/terraform --version && rm ${TEMP_DIR}/terraform-${TERRAFORM_VERSION}.zip

install_tflint:
	wget ${TFLINT_URL} -O ${TEMP_DIR}/tflint-${TFLINT_VERSION}.zip
	unzip -o ${TEMP_DIR}/tflint-${TFLINT_VERSION}.zip -d ${TEMP_DIR}/
	mv ${TEMP_DIR}/tflint ${BIN_DIR}/tflint-${TFLINT_VERSION}
	ln -sf tflint-${TFLINT_VERSION} ${BIN_DIR}/tflint
	${BIN_DIR}/tflint --version && rm ${TEMP_DIR}/tflint-${TFLINT_VERSION}.zip


packer_build_db:
	${BIN_DIR}/packer build -var-file=packer/variables.json packer/db.json

packer_build_app:
	${BIN_DIR}/packer build -var-file=packer/variables.json packer/app.json

packer_validate:
	${BIN_DIR}/packer validate -var-file=packer/variables.json packer/db.json
	${BIN_DIR}/packer validate -var-file=packer/variables.json packer/app.json
	${BIN_DIR}/packer validate -var-file=packer/variables.json packer/ubuntu16.json
	${BIN_DIR}/packer validate -var-file=packer/variables-immutable.json packer/immutable.json


terraform_init:
	cd ./terraform/${ENV} && ${BIN_DIR}/terraform init

terraform_validate:
	cd ./terraform && ${BIN_DIR}/terraform validate
	cd ./terraform/stage && ${BIN_DIR}/terraform validate
	cd ./terraform/prod && ${BIN_DIR}/terraform validate

terraform_tflint:
	cd ./terraform && ${BIN_DIR}/tflint
	cd ./terraform/stage && ${BIN_DIR}/tflint
	cd ./terraform/prod && ${BIN_DIR}/tflint

terraform_apply:
	cd ./terraform/${ENV} && ${BIN_DIR}/terraform apply

terraform_destroy:
	cd ./terraform/${ENV} && ${BIN_DIR}/terraform destroy

terraform_url:
	cd ./terraform/${ENV} && ${BIN_DIR}/terraform output app_url	


ansible_inventory_list:
	cd ./ansible && ../.venv/bin/ansible-inventory -i environments/${ENV}/${INV} --list

ansible_install_requirements:
	cd ./ansible && ../.venv/bin/ansible-galaxy install -r environments/${ENV}/requirements.yml

ansible_lint:
	cd ./ansible && ../.venv/bin/ansible-lint playbooks/*.yml

ansible_syntax:
	cd ./ansible && find playbooks -name "*.yml" -type f -print0 | xargs -0 -n1 ../.venv/bin/ansible-playbook --syntax-check

ansible_site_check:
	cd ./ansible && pwd && ../.venv/bin/ansible-playbook -i environments/${ENV}/${INV} --diff playbooks/site.yml --check

ansible_site_apply:
	echo "Press CTRL+C within 5 seconds to cancel playbook..." && \
	sleep 5 && \
	cd ./ansible && \
	../.venv/bin/ansible-playbook -i environments/${ENV}/${INV} --diff playbooks/site.yml


install: install_packer install_terraform install_tflint install_ansible

validate: packer_validate terraform_validate terraform_tflint ansible_syntax ansible_lint

build: packer_build_db packer_build_app

infra: terraform_init terraform_apply

site: ansible_site_check ansible_site_apply
