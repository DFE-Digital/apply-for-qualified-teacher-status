.DEFAULT_GOAL		:=help
SHELL				:=/bin/bash

SERVICE_SHORT=afqts

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\._\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: paas
paas:  # Set the PaaS platform variables
	$(eval PLATFORM=paas)
	$(eval REGION=West Europe)
	$(eval KEY_VAULT_SECRET_NAME=APPLY-QTS-APP-VARIABLES)
	$(eval KEY_VAULT_PURGE_PROTECTION=true)

.PHONY: aks
aks:  ## Sets environment variables for aks deployment
	$(eval PLATFORM=aks)
	$(eval REGION=UK South)
	$(eval STORAGE_ACCOUNT_SUFFIX=sa)
	$(eval KEY_VAULT_SECRET_NAME=APPLICATION)
	$(eval KEY_VAULT_PURGE_PROTECTION=false)

.PHONY: dev
dev: paas ## Specify development PaaS environment
	$(eval DEPLOY_ENV=dev)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-development)
	$(eval AZURE_RESOURCE_PREFIX=s165d01)
	$(eval CONFIG_SHORT=dv)
	$(eval ENV_TAG=dev)

.PHONY: test
test: paas ## Specify test PaaS environment
	$(eval DEPLOY_ENV=test)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)
	$(eval AZURE_RESOURCE_PREFIX=s165t01)
	$(eval CONFIG_SHORT=ts)
	$(eval ENV_TAG=test)

.PHONY: preprod
preprod: paas ## Specify pre-production PaaS environment
	$(eval DEPLOY_ENV=preprod)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)
	$(eval AZURE_RESOURCE_PREFIX=s165t01)
	$(eval CONFIG_SHORT=pp)
	$(eval ENV_TAG=pre-prod)

.PHONY: production
production: paas ## Specify production PaaS environment
	$(if $(CONFIRM_PRODUCTION), , $(error Can only run with CONFIRM_PRODUCTION))
	$(eval DEPLOY_ENV=production)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-production)
	$(eval AZURE_RESOURCE_PREFIX=s165p01)
	$(eval CONFIG_SHORT=pd)
	$(eval ENV_TAG=prod)
	$(eval AZURE_BACKUP_STORAGE_ACCOUNT_NAME=s165p01afqtsdbbackuppd)
	$(eval AZURE_BACKUP_STORAGE_CONTAINER_NAME=apply-for-qts)



.PHONY: development_aks
development_aks: aks ## Specify development aks environment
	$(eval include global_config/development_aks.sh)

.PHONY: review_aks
review_aks: aks ## Specify review AKS environment
	$(if $(PULL_REQUEST_NUMBER), , $(error Missing environment variable "PULL_REQUEST_NUMBER"))
	$(eval include global_config/review_aks.sh)
	$(eval backend_config=-backend-config="key=terraform-$(PULL_REQUEST_NUMBER).tfstate")
	$(eval export TF_VAR_app_suffix=-$(PULL_REQUEST_NUMBER))
	$(eval export TF_VAR_uploads_storage_account_name=$(AZURE_RESOURCE_PREFIX)afqtsrv$(PULL_REQUEST_NUMBER)sa)

.PHONY: test_aks
test_aks: aks  ##  specify test AKS environment
	$(eval include global_config/test_aks.sh)

.PHONY: preproduction_aks
preproduction_aks: aks  ##  specify preproduction AKS environment
	$(eval include global_config/preproduction_aks.sh)

.PHONY: production_aks
production_aks: aks   ##  specify production AKS environment
	$(eval include global_config/production_aks.sh)

.PHONY: set-key-vault-names
set-key-vault-names:
	$(if $(KEY_VAULT_SECRET_NAME), , $(error Missing environment variable "KEY_VAULT_SECRET_NAME"))
	$(eval KEY_VAULT_NAME=$(AZURE_RESOURCE_PREFIX)-$(SERVICE_SHORT)-$(CONFIG_SHORT)-kv)
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

.PHONY: print-resource-group-name
print-resource-group-name: set-resource-group-name
	echo ${RESOURCE_GROUP_NAME}

.PHONY: read-deployment-config
read-deployment-config:
	$(if $(PLATFORM), , $(error Missing environment variable "PLATFORM"))
	$(eval SPACE=$(shell jq -r '.paas_space' terraform/$(PLATFORM)/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval POSTGRES_DATABASE_NAME="apply-for-qts-in-england-$(DEPLOY_ENV)-pg-svc")
	$(eval API_APP_NAME="apply-for-qts-in-england-$(DEPLOY_ENV)")

.PHONY: set-azure-account
set-azure-account:
	echo "Logging on to ${AZURE_SUBSCRIPTION}"
	az account set -s ${AZURE_SUBSCRIPTION}

.PHONY: ci
ci:	## Run in automation environment
	$(eval DISABLE_PASSCODE=true)
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SP_AUTH=true)
	$(eval CONFIRM_PRODUCTION=true)

bin/fetch_config.rb:
	curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb

bin/konduit.sh:
	curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/main/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh

.PHONY: install-konduit
install-konduit: bin/konduit.sh ## Install the konduit script, for accessing backend services

.PHONY: edit-keyvault-secret
edit-keyvault-secret: bin/fetch_config.rb set-key-vault-names set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} \
		-e -d azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml -c

.PHONY: print-keyvault-secret
print-keyvault-secret: bin/fetch_config.rb set-key-vault-names set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml

.PHONY: validate-keyvault-secret
validate-keyvault-secret: bin/fetch_config.rb set-key-vault-names set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -d quiet \
		&& echo Data in ${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} looks valid

.PHONY: set-space-developer
set-space-developer: read-deployment-config ## make production set-space-developer USER_ID=first.last@digital.education.gov.uk
	$(if $(USER_ID), , $(error Missing environment variable "USER_ID", USER_ID required for this command to run))
	cf set-space-role ${USER_ID} dfe ${SPACE} SpaceDeveloper

.PHONY: unset-space-developer
unset-space-developer: read-deployment-config ## make production unset-space-developer USER_ID=first.last@digital.education.gov.uk
	$(if $(USER_ID), , $(error Missing environment variable "USER_ID", USER_ID required for this command to run))
	cf unset-space-role ${USER_ID} dfe ${SPACE} SpaceDeveloper

.PHONY: stop-app
stop-app: read-deployment-config ## Stops api app, make production stop-app CONFIRM_STOP=1
	$(if $(CONFIRM_STOP), , $(error stop-app can only run with CONFIRM_STOP))
	cf target -s ${SPACE}
	cf stop ${API_APP_NAME}

.PHONY: get-postgres-instance-guid
get-postgres-instance-guid: read-deployment-config ## Gets the postgres service instance's guid
	cf target -s ${SPACE} > /dev/null
	cf service ${POSTGRES_DATABASE_NAME} --guid
	$(eval DB_INSTANCE_GUID=$(shell cf service ${POSTGRES_DATABASE_NAME} --guid))

.PHONY: rename-postgres-service
rename-postgres-service: read-deployment-config ## make production rename-postgres-service NEW_NAME_SUFFIX=old CONFIRM_RENAME
	$(if $(CONFIRM_RENAME), , $(error can only run with CONFIRM_RENAME))
	$(if $(NEW_NAME_SUFFIX), , $(error NEW_NAME_SUFFIX is required))
	cf target -s ${SPACE} > /dev/null
	cf rename-service  ${POSTGRES_DATABASE_NAME} ${POSTGRES_DATABASE_NAME}-$(NEW_NAME_SUFFIX)

.PHONY: remove-postgres-tf-state
remove-postgres-tf-state: terraform-init ## make production remove-postgres-tf-state PASSCODE=XXX
	cd terraform/paas && terraform state rm cloudfoundry_service_instance.postgres

.PHONY: restore-postgres
restore-postgres: terraform-init read-deployment-config ## make production restore-postgres DB_INSTANCE_GUID="<cf service db-name --guid>" BEFORE_TIME="yyyy-MM-dd hh:mm:ss" DOCKER_IMAGE=ghcr.io/dfe-digital/apply-for-qualified-teacher-status:<COMMIT_SHA> PASSCODE=<auth code from https://login.london.cloud.service.gov.uk/passcode>
	cf target -s ${SPACE} > /dev/null
	$(if $(DB_INSTANCE_GUID), , $(error can only run with DB_INSTANCE_GUID, get it by running `make production get-postgres-instance-guid`))
	$(if $(BEFORE_TIME), , $(error can only run with BEFORE_TIME, eg BEFORE_TIME="2021-09-14 16:00:00"))
	$(eval export TF_VAR_paas_restore_db_from_db_instance=$(DB_INSTANCE_GUID))
	$(eval export TF_VAR_paas_restore_db_from_point_in_time_before=$(BEFORE_TIME))
	echo "Restoring ${POSTGRES_DATABASE_NAME} from $(TF_VAR_paas_restore_db_from_db_instance) before $(TF_VAR_paas_restore_db_from_point_in_time_before)"
	make ${DEPLOY_ENV} terraform-apply

.PHONY: restore-data-from-backup
restore-data-from-backup: read-deployment-config # make production restore-data-from-backup CONFIRM_RESTORE=YES BACKUP_FILENAME="apply-for-qts-in-england-production-pg-svc-2022-07-06-01"
	@if [[ "$(CONFIRM_RESTORE)" != YES ]]; then echo "Please enter "CONFIRM_RESTORE=YES" to run workflow"; exit 1; fi
	$(eval export AZURE_BACKUP_STORAGE_ACCOUNT_NAME=$(AZURE_BACKUP_STORAGE_ACCOUNT_NAME))
	$(if $(BACKUP_FILENAME), , $(error can only run with BACKUP_FILENAME, eg BACKUP_FILENAME="find-a-lost-trn-production-pg-svc-2022-04-28-01"))
	bin/download-db-backup ${AZURE_BACKUP_STORAGE_ACCOUNT_NAME} ${AZURE_BACKUP_STORAGE_CONTAINER_NAME} ${BACKUP_FILENAME}.tar.gz
	bin/restore-db ${DEPLOY_ENV} ${CONFIRM_RESTORE} ${SPACE} ${BACKUP_FILENAME}.sql ${POSTGRES_DATABASE_NAME}

.PHONY: terraform-init
terraform-init:
	$(if $(or $(DISABLE_PASSCODE),$(PASSCODE)), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	$(if $(DOCKER_IMAGE), , $(error Missing environment variable "DOCKER_IMAGE"))
	$(if $(PLATFORM), , $(error Missing environment variable "PLATFORM"))

	$(eval export TF_VAR_apply_qts_docker_image=$(DOCKER_IMAGE))
	$(eval export TF_VAR_docker_image=$(DOCKER_IMAGE))

	$(eval export TF_VAR_config_short=$(CONFIG_SHORT))
	$(eval export TF_VAR_service_short=$(SERVICE_SHORT))
	$(eval export TF_VAR_azure_resource_prefix=$(AZURE_RESOURCE_PREFIX))

	[[ "${SP_AUTH}" != "true" ]] && az account show && az account set -s $(AZURE_SUBSCRIPTION) || true
	terraform -chdir=terraform/$(PLATFORM) init -backend-config workspace_variables/${DEPLOY_ENV}.backend.tfvars $(backend_config) -upgrade -reconfigure

.PHONY: terraform-plan
terraform-plan: terraform-init
	terraform -chdir=terraform/$(PLATFORM) plan -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

.PHONY: terraform-refresh
terraform-refresh: terraform-init
	terraform -chdir=terraform/$(PLATFORM) refresh -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

.PHONY: terraform-apply
terraform-apply: terraform-init
	terraform -chdir=terraform/$(PLATFORM) apply -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

.PHONY: terraform-destroy
terraform-destroy: terraform-init
	terraform -chdir=terraform/$(PLATFORM) destroy -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

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
arm-deployment: set-resource-group-name set-azure-account set-azure-template-tag set-azure-resource-group-tags set-key-vault-names
	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "${REGION}" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_GROUP_NAME}" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${AZURE_RESOURCE_PREFIX}${SERVICE_SHORT}tfstate${CONFIG_SHORT}${STORAGE_ACCOUNT_SUFFIX}" "tfStorageContainerName=${SERVICE_SHORT}-tfstate" \
			keyVaultNames='("${KEY_VAULT_APPLICATION_NAME}", "${KEY_VAULT_INFRASTRUCTURE_NAME}")' \
			"enableKVPurgeProtection=${KEY_VAULT_PURGE_PROTECTION}" ${WHAT_IF}

.PHONY: deploy-azure-resources
deploy-azure-resources: check-auto-approve arm-deployment # make dev deploy-azure-resources AUTO_APPROVE=1

.PHONY: validate-azure-resources
validate-azure-resources: set-what-if arm-deployment # make dev validate-azure-resources

.PHONY: read-tf-config
read-tf-config:
	$(if $(PLATFORM), , $(error Missing environment variable "PLATFORM"))
	$(eval space=$(shell jq -r '.paas_space' terraform/$(PLATFORM)/workspace_variables/$(DEPLOY_ENV).tfvars.json))

.PHONY: enable-maintenance
enable-maintenance: read-tf-config ## make dev enable-maintenance / make production enable-maintenance CONFIRM_PRODUCTION=y
	cf target -s ${space}
	cd service_unavailable_page && cf push
	cf map-route apply-for-qts-unavailable london.cloudapps.digital --hostname apply-for-qts-in-england-${DEPLOY_ENV}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route apply-for-qts-in-england-${DEPLOY_ENV} london.cloudapps.digital --hostname apply-for-qts-in-england-${DEPLOY_ENV}

.PHONY: disable-maintenance
disable-maintenance: read-tf-config ## make dev disable-maintenance / make production disable-maintenance CONFIRM_PRODUCTION=y
	cf target -s ${space}
	cf map-route apply-for-qts-in-england-${DEPLOY_ENV} london.cloudapps.digital --hostname apply-for-qts-in-england-${DEPLOY_ENV}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route apply-for-qts-unavailable london.cloudapps.digital --hostname apply-for-qts-in-england-${DEPLOY_ENV}
	cf delete apply-for-qts-unavailable -r -f

validate-domain-resources: set-what-if domain-azure-resources # make publish validate-domain-resources AUTO_APPROVE=1

deploy-domain-resources: check-auto-approve domain-azure-resources # make publish deploy-domain-resources AUTO_APPROVE=1

.PHONY: afqts_domain
afqts_domain:   ## runs a script to config variables for setting up dns
	$(eval include global_config/domain.sh)

domains-infra-init: afqts_domain set-production-subscription set-azure-account ## make domains-infra-init -  terraform init for dns core resources, eg Main FrontDoor resource
	terraform -chdir=terraform/custom_domains/infrastructure init -reconfigure -upgrade \
		-backend-config=workspace_variables/${DOMAINS_ID}_backend.tfvars

domains-infra-plan: domains-infra-init ## terraform plan for dns core resources
	terraform -chdir=terraform/custom_domains/infrastructure plan -var-file workspace_variables/${DOMAINS_ID}.tfvars.json

domains-infra-apply: domains-infra-init ## terraform apply for dns core resources
	terraform -chdir=terraform/custom_domains/infrastructure apply -var-file workspace_variables/${DOMAINS_ID}.tfvars.json ${AUTO_APPROVE}

domains-init: afqts_domain set-production-subscription set-azure-account ## terraform init for dns resources: make <env>  domains-init
	terraform -chdir=terraform/custom_domains/environment_domains init -upgrade -reconfigure -backend-config=workspace_variables/${DEPLOY_ENV}_backend.tfvars

domains-plan: domains-init  ## terraform plan for dns resources, eg dev.<domain_name> dns records and frontdoor routing
	terraform -chdir=terraform/custom_domains/environment_domains plan -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

domains-apply: domains-init ## terraform apply for dns resources
	terraform -chdir=terraform/custom_domains/environment_domains apply -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

domains-destroy: domains-init ## terraform destroy for dns resources
	terraform -chdir=terraform/custom_domains/environment_domains destroy -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

domains-development:
	$(eval DEPLOY_ENV=dev)

domains-test:
	$(eval DEPLOY_ENV=test)

set-production-subscription:
	$(eval AZ_SUBSCRIPTION=s189-teacher-services-cloud-production)

domain-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags ## deploy container to store terraform state for all dns resources -run validate first
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "${DNS_ZONE}domains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${DNS_ZONE}domainstf" "tfStorageContainerName=${DNS_ZONE}domains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-kv" ${WHAT_IF}

validate-domain-resources: set-what-if domain-azure-resources ## make  validate-domain-resources  - validate resource against Azure
