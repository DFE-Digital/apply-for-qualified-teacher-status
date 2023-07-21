.DEFAULT_GOAL		:=help
SHELL				:=/bin/bash

SERVICE_SHORT=afqts
KEY_VAULT_PURGE_PROTECTION=false

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\._\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: development
development: ## Specify development configuration
	$(eval include global_config/development.sh)

.PHONY: review
review: ## Specify review configuration
	$(if $(PULL_REQUEST_NUMBER), , $(error Missing environment variable "PULL_REQUEST_NUMBER"))
	$(eval include global_config/review.sh)
	$(eval TERRAFORM_BACKEND_KEY=terraform-$(PULL_REQUEST_NUMBER).tfstate)
	$(eval export TF_VAR_app_suffix=-$(PULL_REQUEST_NUMBER))
	$(eval export TF_VAR_uploads_storage_account_name=$(AZURE_RESOURCE_PREFIX)afqtsrv$(PULL_REQUEST_NUMBER)sa)

.PHONY: test
test:  ## Specify test configuration
	$(eval include global_config/test.sh)

.PHONY: preproduction
preproduction: ## Specify preproduction configuration
	$(eval include global_config/preproduction.sh)

.PHONY: production
production:  ## Specify production configuration
	$(eval include global_config/production.sh)

.PHONY: domains
domains:  ## Specify domains configuration
	$(eval include global_config/domains.sh)

.PHONY: set-key-vault-names
set-key-vault-names:
	$(eval KEY_VAULT_APPLICATION_NAME=$(AZURE_RESOURCE_PREFIX)-$(SERVICE_SHORT)-$(CONFIG_SHORT)-app-kv)
	$(eval KEY_VAULT_INFRASTRUCTURE_NAME=$(AZURE_RESOURCE_PREFIX)-$(SERVICE_SHORT)-$(CONFIG_SHORT)-inf-kv)

.PHONY: print-application-key-vault-name
print-application-key-vault-name: set-key-vault-names  ## Print the name of the application key vault
	echo ${KEY_VAULT_APPLICATION_NAME}

.PHONY: print-infrastructure-key-vault-name
print-infrastructure-key-vault-name: set-key-vault-names  ## Print the name of the infrastructure key vault
	echo ${KEY_VAULT_INFRASTRUCTURE_NAME}

.PHONY: set-resource-group-name
set-resource-group-name:
	$(eval RESOURCE_GROUP_NAME=$(AZURE_RESOURCE_PREFIX)-$(SERVICE_SHORT)-$(CONFIG_SHORT)-rg)

.PHONY: set-storage-account-name
set-storage-account-name:
	$(eval STORAGE_ACCOUNT_NAME=$(AZURE_RESOURCE_PREFIX)$(SERVICE_SHORT)tfstate$(CONFIG_SHORT)sa)

.PHONY: print-resource-group-name
print-resource-group-name: set-resource-group-name
	echo ${RESOURCE_GROUP_NAME}

.PHONY: set-azure-account
set-azure-account:
	[ "${SKIP_AZURE_LOGIN}" != "true" ] && az account set -s ${AZURE_SUBSCRIPTION} || true

.PHONY: ci
ci:	## Run in automation environment
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SKIP_AZURE_LOGIN=true)
	$(eval CONFIRM_PRODUCTION=true)

bin/konduit.sh:
	curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/main/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh

.PHONY: install-konduit
install-konduit: bin/konduit.sh ## Install the konduit script, for accessing backend services

.PHONY: terraform-init
terraform-init: set-resource-group-name set-storage-account-name set-azure-account
	$(if $(DOCKER_IMAGE), , $(error Missing environment variable "DOCKER_IMAGE"))

	$(eval export TF_VAR_docker_image=$(DOCKER_IMAGE))
	$(eval export TF_VAR_config_short=$(CONFIG_SHORT))
	$(eval export TF_VAR_service_short=$(SERVICE_SHORT))
	$(eval export TF_VAR_azure_resource_prefix=$(AZURE_RESOURCE_PREFIX))

	terraform -chdir=terraform/application init -upgrade -reconfigure \
		-backend-config=resource_group_name=$(RESOURCE_GROUP_NAME) \
		-backend-config=storage_account_name=$(STORAGE_ACCOUNT_NAME) \
		-backend-config=key=$(or $(TERRAFORM_BACKEND_KEY),terraform.tfstate)

.PHONY: terraform-plan
terraform-plan: terraform-init
	terraform -chdir=terraform/application plan -var-file config/$(CONFIG).tfvars.json

.PHONY: terraform-refresh
terraform-refresh: terraform-init
	terraform -chdir=terraform/application refresh -var-file config/$(CONFIG).tfvars.json

.PHONY: terraform-apply
terraform-apply: terraform-init
	terraform -chdir=terraform/application apply -var-file config/$(CONFIG).tfvars.json ${AUTO_APPROVE}

.PHONY: terraform-destroy
terraform-destroy: terraform-init
	terraform -chdir=terraform/application destroy -var-file config/$(CONFIG).tfvars.json ${AUTO_APPROVE}

.PHONY: set-azure-resource-group-tags
set-azure-resource-group-tags: ##Tags that will be added to resource group on its creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early years and Schools Group", "Parent Business":"Teaching Regulation Agency", "Product" : "Apply for QTS in England", "Service Line": "Teaching Workforce", "Service": "Teacher Services", "Service Offering": "Apply for QTS in England", "Environment" : "$(ENV_TAG)"}' | jq . ))

.PHONY: set-azure-template-tag
set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.1.6)

.PHONY: set-what-if
set-what-if:
	$(eval WHAT_IF=--what-if)

.PHONY: check-auto-approve
check-auto-approve:
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))

.PHONY: arm-deployment
arm-deployment: set-resource-group-name set-storage-account-name set-azure-account set-azure-template-tag set-azure-resource-group-tags set-key-vault-names
	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_GROUP_NAME}" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${STORAGE_ACCOUNT_NAME}" "tfStorageContainerName=${SERVICE_SHORT}-tfstate" \
			keyVaultNames='("${KEY_VAULT_APPLICATION_NAME}", "${KEY_VAULT_INFRASTRUCTURE_NAME}")' \
			"enableKVPurgeProtection=${KEY_VAULT_PURGE_PROTECTION}" ${WHAT_IF}

.PHONY: deploy-azure-resources
deploy-azure-resources: check-auto-approve arm-deployment # make development deploy-azure-resources AUTO_APPROVE=1

.PHONY: validate-azure-resources
validate-azure-resources: set-what-if arm-deployment # make development validate-azure-resources

validate-domain-resources: set-what-if domain-azure-resources # make publish validate-domain-resources AUTO_APPROVE=1

deploy-domain-resources: check-auto-approve domain-azure-resources # make publish deploy-domain-resources AUTO_APPROVE=1

domains-infra-init: domains set-azure-account ## make domains-infra-init -  terraform init for dns core resources, eg Main FrontDoor resource
	terraform -chdir=terraform/domains/infrastructure init -reconfigure -upgrade

domains-infra-plan: domains-infra-init ## terraform plan for dns core resources
	terraform -chdir=terraform/domains/infrastructure plan -var-file config/zones.tfvars.json

domains-infra-apply: domains-infra-init ## terraform apply for dns core resources
	terraform -chdir=terraform/domains/infrastructure apply -var-file config/zones.tfvars.json ${AUTO_APPROVE}

domains-init: domains set-azure-account ## terraform init for dns resources: make <env>  domains-init
	terraform -chdir=terraform/domains/environment_domains init -upgrade -reconfigure -backend-config=key=$(or $(DOMAINS_TERRAFORM_BACKEND_KEY),afqtsdomains_$(CONFIG).tfstate)

domains-plan: domains-init  ## terraform plan for dns resources, eg dev.<domain_name> dns records and frontdoor routing
	terraform -chdir=terraform/domains/environment_domains plan -var-file config/$(CONFIG).tfvars.json

domains-apply: domains-init ## terraform apply for dns resources
	terraform -chdir=terraform/domains/environment_domains apply -var-file config/$(CONFIG).tfvars.json ${AUTO_APPROVE}

domains-destroy: domains-init ## terraform destroy for dns resources
	terraform -chdir=terraform/domains/environment_domains destroy -var-file config/$(CONFIG).tfvars.json

domain-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags ## deploy container to store terraform state for all dns resources -run validate first
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "afqtsdomains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${AZURE_RESOURCE_PREFIX}-afqtsdomains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${AZURE_RESOURCE_PREFIX}afqtsdomainstf" "tfStorageContainerName=afqtsdomains-tf"  "keyVaultName=${AZURE_RESOURCE_PREFIX}-afqtsdomains-kv" ${WHAT_IF}

validate-domain-resources: set-what-if domain-azure-resources ## make  validate-domain-resources  - validate resource against Azure
