.DEFAULT_GOAL		:=help
SHELL				:=/bin/bash

SERVICE_SHORT=afqts
KEY_VAULT_PURGE_PROTECTION=false
ARM_TEMPLATE_TAG=1.1.6
TERRAFILE_VERSION=0.8

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\._\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: development
development: set-test-azure-subscription test-cluster ## Specify development configuration
	$(eval CONFIG=development)
	$(eval CONFIG_SHORT=dv)
	$(eval DOMAINS_TERRAFORM_BACKEND_KEY=afqtsdomains_dev.tfstate)

.PHONY: review
review: set-test-azure-subscription test-cluster ## Specify review configuration
	$(if $(PULL_REQUEST_NUMBER), , $(error Missing environment variable "PULL_REQUEST_NUMBER"))
	$(eval CONFIG=review)
	$(eval CONFIG_SHORT=rv)
	$(eval TERRAFORM_BACKEND_KEY=terraform-$(PULL_REQUEST_NUMBER).tfstate)
	$(eval export TF_VAR_app_suffix=-$(PULL_REQUEST_NUMBER))
	$(eval export TF_VAR_uploads_storage_account_name=$(AZURE_RESOURCE_PREFIX)afqtsrv$(PULL_REQUEST_NUMBER)sa)

.PHONY: test
test: set-test-azure-subscription test-cluster ## Specify test configuration
	$(eval CONFIG=test)
	$(eval CONFIG_SHORT=ts)

.PHONY: preproduction
preproduction: set-test-azure-subscription test-cluster ## Specify preproduction configuration
	$(eval CONFIG=preproduction)
	$(eval CONFIG_SHORT=pp)
	$(eval DOMAINS_TERRAFORM_BACKEND_KEY=afqtsdomains_preprod.tfstate)

.PHONY: production
production: set-production-azure-subscription production-cluster ## Specify production configuration
	$(eval CONFIG=production)
	$(eval CONFIG_SHORT=pd)
	$(eval KEY_VAULT_PURGE_PROTECTION=true)

.PHONY: set-test-azure-subscription
set-test-azure-subscription:
	$(eval AZURE_SUBSCRIPTION=s189-teacher-services-cloud-test)
	$(eval AZURE_RESOURCE_PREFIX=s189t01)
	$(eval AZURE_ENV_TAG=Test)

.PHONY: set-production-azure-subscription
set-production-azure-subscription:
	$(eval AZURE_SUBSCRIPTION=s189-teacher-services-cloud-production)
	$(eval AZURE_RESOURCE_PREFIX=s189p01)
	$(eval AZURE_ENV_TAG=Prod)

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

bin/terrafile:
	curl -sL https://github.com/coretech/terrafile/releases/download/v${TERRAFILE_VERSION}/terrafile_${TERRAFILE_VERSION}_$$(uname)_x86_64.tar.gz \
		| tar xz -C ./bin terrafile

.PHONY: install-konduit
install-konduit: bin/konduit.sh ## Install the konduit script, for accessing backend services

.PHONY: terrafile
terrafile: bin/terrafile
	./bin/terrafile -p terraform/application/vendor/modules \
		-f terraform/application/config/$(CONFIG)/Terrafile

.PHONY: terraform-init
terraform-init: set-resource-group-name set-storage-account-name set-azure-account terrafile
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
	terraform -chdir=terraform/application plan -var-file config/$(CONFIG)/variables.tfvars.json

.PHONY: terraform-refresh
terraform-refresh: terraform-init
	terraform -chdir=terraform/application refresh -var-file config/$(CONFIG)/variables.tfvars.json

.PHONY: terraform-apply
terraform-apply: terraform-init
	terraform -chdir=terraform/application apply -var-file config/$(CONFIG)/variables.tfvars.json ${AUTO_APPROVE}

.PHONY: terraform-destroy
terraform-destroy: terraform-init
	terraform -chdir=terraform/application destroy -var-file config/$(CONFIG)/variables.tfvars.json ${AUTO_APPROVE}

.PHONY: set-azure-resource-group-tags
set-azure-resource-group-tags: ##Tags that will be added to resource group on its creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early years and Schools Group", "Parent Business":"Teaching Regulation Agency", "Product" : "Apply for QTS in England", "Service Line": "Teaching Workforce", "Service": "Teacher Services", "Service Offering": "Apply for QTS in England", "Environment" : "$(AZURE_ENV_TAG)"}' | jq . ))

.PHONY: set-what-if
set-what-if:
	$(eval WHAT_IF=--what-if)

.PHONY: check-auto-approve
check-auto-approve:
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))

.PHONY: arm-deployment
arm-deployment: set-resource-group-name set-storage-account-name set-azure-account set-azure-resource-group-tags set-key-vault-names
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

.PHONY: domains-arm-deployment
domains-arm-deployment: set-azure-account set-azure-resource-group-tags
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "afqtsdomains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${AZURE_RESOURCE_PREFIX}-afqtsdomains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${AZURE_RESOURCE_PREFIX}afqtsdomainstf" "tfStorageContainerName=afqtsdomains-tf"  "keyVaultName=${AZURE_RESOURCE_PREFIX}-afqtsdomains-kv" ${WHAT_IF}

.PHONY: validate-azure-domains-resources
validate-azure-domains-resources: set-production-azure-subscription set-what-if domains-arm-deployment # make deploy-azure-domains-resources AUTO_APPROVE=1

.PHONY: deploy-azure-domains-resources
deploy-azure-domains-resources: set-production-azure-subscription check-auto-approve domains-arm-deployment # make validate-azure-domains-resources

domains-infra-init: set-production-azure-subscription set-azure-account ## make domains-infra-init -  terraform init for dns core resources, eg Main FrontDoor resource
	terraform -chdir=terraform/domains/infrastructure init -reconfigure -upgrade

domains-infra-plan: domains-infra-init ## terraform plan for dns core resources
	terraform -chdir=terraform/domains/infrastructure plan -var-file config/zones.tfvars.json

domains-infra-apply: domains-infra-init ## terraform apply for dns core resources
	terraform -chdir=terraform/domains/infrastructure apply -var-file config/zones.tfvars.json ${AUTO_APPROVE}

domains-init: set-production-azure-subscription set-azure-account ## terraform init for dns resources: make <env>  domains-init
	terraform -chdir=terraform/domains/environment_domains init -upgrade -reconfigure -backend-config=key=$(or $(DOMAINS_TERRAFORM_BACKEND_KEY),afqtsdomains_$(CONFIG).tfstate)

domains-plan: domains-init  ## terraform plan for dns resources, eg dev.<domain_name> dns records and frontdoor routing
	terraform -chdir=terraform/domains/environment_domains plan -var-file config/$(CONFIG).tfvars.json

domains-apply: domains-init ## terraform apply for dns resources
	terraform -chdir=terraform/domains/environment_domains apply -var-file config/$(CONFIG).tfvars.json ${AUTO_APPROVE}

domains-destroy: domains-init ## terraform destroy for dns resources
	terraform -chdir=terraform/domains/environment_domains destroy -var-file config/$(CONFIG).tfvars.json

test-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189t01-tsc-ts-rg)
	$(eval CLUSTER_NAME=s189t01-tsc-test-aks)

production-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189p01-tsc-pd-rg)
	$(eval CLUSTER_NAME=s189p01-tsc-production-aks)

get-cluster-credentials: set-azure-account
	az aks get-credentials --overwrite-existing -g ${CLUSTER_RESOURCE_GROUP_NAME} -n ${CLUSTER_NAME}
	kubelogin convert-kubeconfig -l $(if ${GITHUB_ACTIONS},spn,azurecli)
