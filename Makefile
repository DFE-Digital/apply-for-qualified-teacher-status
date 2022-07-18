.DEFAULT_GOAL		:=help
SHELL				:=/bin/bash

.PHONY: help # default target
help: ## Show this help
	@grep -E '^[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
    $(eval AZURE_BACKUP_STORAGE_ACCOUNT_NAME=false)
    $(eval AZURE_BACKUP_STORAGE_CONTAINER_NAME=false)

.PHONY: dev
dev:
	$(eval DEPLOY_ENV=dev)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-development)
	$(eval RESOURCE_NAME_PREFIX=s165d01)
	$(eval ENV_SHORT=dv)
	$(eval ENV_TAG=dev)

.PHONY: test
test:
	$(eval DEPLOY_ENV=test)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)
	$(eval RESOURCE_NAME_PREFIX=s165t01)
	$(eval ENV_SHORT=ts)
	$(eval ENV_TAG=test)

.PHONY: preprod
preprod:
	$(eval DEPLOY_ENV=preprod)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)
	$(eval RESOURCE_NAME_PREFIX=s165t01)
	$(eval ENV_SHORT=pp)
	$(eval ENV_TAG=pre-prod)

.PHONY: production
production:
	$(eval DEPLOY_ENV=production)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-production)
	$(eval RESOURCE_NAME_PREFIX=s165p01)
	$(eval ENV_SHORT=pd)
	$(eval ENV_TAG=prod)
	$(eval AZURE_BACKUP_STORAGE_ACCOUNT_NAME=s165p01afqtsdbbackuppd)
	$(eval AZURE_BACKUP_STORAGE_CONTAINER_NAME=apply-for-qts)

.PHONY: review
review:
	$(if $(pr_id), , $(error Missing environment variable "pr_id"))
	$(eval DEPLOY_ENV=review)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-development)
	$(eval RESOURCE_NAME_PREFIX=s165d01)
	$(eval ENV_SHORT=rv)
	$(eval ENV_TAG=rev)
	$(eval env=-pr-$(pr_id))
	$(eval backend_config=-backend-config="key=review/review$(env).tfstate")
	$(eval export TF_VAR_app_suffix=$(env))

read-keyvault-config:
	$(eval KEY_VAULT_NAME=$(shell jq -r '.key_vault_name' terraform/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval KEY_VAULT_SECRET_NAME=APPLY-QTS-APP-VARIABLES)

read-deployment-config:
	$(eval SPACE=$(shell jq -r '.paas_space' terraform/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval POSTGRES_DATABASE_NAME="apply-for-qts-in-england-$(DEPLOY_ENV)-pg-svc")
	$(eval API_APP_NAME="apply-for-qts-in-england-$(DEPLOY_ENV)")

set-azure-account: ${environment}
	echo "Logging on to ${AZURE_SUBSCRIPTION}"
	az account set -s ${AZURE_SUBSCRIPTION}

ci:	## Run in automation environment
	$(eval DISABLE_PASSCODE=true)
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SP_AUTH=true)

tags: ##Tags that will be added to resource group on it's creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early years and Schools Group", "Parent Business":"Teaching Regulation Agency", "Product" : "Apply for QTS in England", "Service Line": "Teaching Workforce", "Service": "Teacher Services", "Service Offering": "Apply for QTS in England", "Environment" : "$(ENV_TAG)"}' | jq . ))

.PHONY: install-fetch-config
install-fetch-config: ## Install the fetch-config script, for viewing/editing secrets in Azure Key Vault
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

edit-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} \
		-e -d azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml -c

print-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml

validate-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account
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

stop-app: read-deployment-config ## Stops api app, make production stop-app CONFIRM_STOP=1
	$(if $(CONFIRM_STOP), , $(error stop-app can only run with CONFIRM_STOP))
	cf target -s ${SPACE}
	cf stop ${API_APP_NAME}

get-postgres-instance-guid: read-deployment-config ## Gets the postgres service instance's guid
	cf target -s ${SPACE} > /dev/null
	cf service ${POSTGRES_DATABASE_NAME} --guid
	$(eval DB_INSTANCE_GUID=$(shell cf service ${POSTGRES_DATABASE_NAME} --guid))

rename-postgres-service: read-deployment-config ## make production rename-postgres-service NEW_NAME_SUFFIX=old CONFIRM_RENAME
	$(if $(CONFIRM_RENAME), , $(error can only run with CONFIRM_RENAME))
	$(if $(NEW_NAME_SUFFIX), , $(error NEW_NAME_SUFFIX is required))
	cf target -s ${SPACE} > /dev/null
	cf rename-service  ${POSTGRES_DATABASE_NAME} ${POSTGRES_DATABASE_NAME}-$(NEW_NAME_SUFFIX)

remove-postgres-tf-state: terraform-init ## make production remove-postgres-tf-state PASSCODE=XXX
	cd terraform && terraform state rm cloudfoundry_service_instance.postgres

restore-postgres: terraform-init read-deployment-config ## make production restore-postgres DB_INSTANCE_GUID="<cf service db-name --guid>" BEFORE_TIME="yyyy-MM-dd hh:mm:ss" TF_VAR_apply_qts_docker_image=ghcr.io/dfe-digital/apply-for-qualified-teacher-status:<COMMIT_SHA> PASSCODE=<auth code from https://login.london.cloud.service.gov.uk/passcode>
	cf target -s ${SPACE} > /dev/null
	$(if $(DB_INSTANCE_GUID), , $(error can only run with DB_INSTANCE_GUID, get it by running `make production get-postgres-instance-guid`))
	$(if $(BEFORE_TIME), , $(error can only run with BEFORE_TIME, eg BEFORE_TIME="2021-09-14 16:00:00"))
	$(eval export TF_VAR_paas_restore_db_from_db_instance=$(DB_INSTANCE_GUID))
	$(eval export TF_VAR_paas_restore_db_from_point_in_time_before=$(BEFORE_TIME))
	echo "Restoring ${POSTGRES_DATABASE_NAME} from $(TF_VAR_paas_restore_db_from_db_instance) before $(TF_VAR_paas_restore_db_from_point_in_time_before)"
	make ${DEPLOY_ENV} terraform-apply

restore-data-from-backup: read-deployment-config # make production restore-data-from-backup CONFIRM_RESTORE=YES BACKUP_FILENAME="apply-for-qts-in-england-production-pg-svc-2022-07-06-01"
	@if [[ "$(CONFIRM_RESTORE)" != YES ]]; then echo "Please enter "CONFIRM_RESTORE=YES" to run workflow"; exit 1; fi
	$(eval export AZURE_BACKUP_STORAGE_ACCOUNT_NAME=$(AZURE_BACKUP_STORAGE_ACCOUNT_NAME))
	$(if $(BACKUP_FILENAME), , $(error can only run with BACKUP_FILENAME, eg BACKUP_FILENAME="find-a-lost-trn-production-pg-svc-2022-04-28-01"))
	bin/download-db-backup ${AZURE_BACKUP_STORAGE_ACCOUNT_NAME} ${AZURE_BACKUP_STORAGE_CONTAINER_NAME} ${BACKUP_FILENAME}.tar.gz
	bin/restore-db ${DEPLOY_ENV} ${CONFIRM_RESTORE} ${SPACE} ${BACKUP_FILENAME}.sql ${POSTGRES_DATABASE_NAME}

terraform-init:
	$(if $(or $(DISABLE_PASSCODE),$(PASSCODE)), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	[[ "${SP_AUTH}" != "true" ]] && az account show && az account set -s $(AZURE_SUBSCRIPTION) || true
	terraform -chdir=terraform init -backend-config workspace_variables/${DEPLOY_ENV}.backend.tfvars $(backend_config) -upgrade -reconfigure

terraform-plan: terraform-init
	terraform -chdir=terraform plan -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

terraform-apply: terraform-init
	terraform -chdir=terraform apply -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

terraform-destroy: terraform-init
	terraform -chdir=terraform destroy -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

deploy-azure-resources: set-azure-account tags # make dev deploy-azure-resources CONFIRM_DEPLOY=1
	$(if $(CONFIRM_DEPLOY), , $(error can only run with CONFIRM_DEPLOY))
	az deployment sub create -l "West Europe" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/main/azure/resourcedeploy.json" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-afqts-${ENV_SHORT}-rg" 'tags=${RG_TAGS}' "environment=${DEPLOY_ENV}" "tfStorageAccountName=${RESOURCE_NAME_PREFIX}afqtstfstate${ENV_SHORT}" "tfStorageContainerName=afqts-tfstate" "dbBackupStorageAccountName=${AZURE_BACKUP_STORAGE_ACCOUNT_NAME}" "dbBackupStorageContainerName=${AZURE_BACKUP_STORAGE_CONTAINER_NAME}" "keyVaultName=${RESOURCE_NAME_PREFIX}-afqts-${ENV_SHORT}-kv"

validate-azure-resources: set-azure-account  tags# make dev validate-azure-resources
	az deployment sub create -l "West Europe" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/main/azure/resourcedeploy.json" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-afqts-${ENV_SHORT}-rg" 'tags=${RG_TAGS}' "environment=${DEPLOY_ENV}" "tfStorageAccountName=${RESOURCE_NAME_PREFIX}afqtstfstate${ENV_SHORT}" "tfStorageContainerName=afqts-tfstate" "dbBackupStorageAccountName=${AZURE_BACKUP_STORAGE_ACCOUNT_NAME}" "dbBackupStorageContainerName=${AZURE_BACKUP_STORAGE_CONTAINER_NAME}" "keyVaultName=${RESOURCE_NAME_PREFIX}-afqts-${ENV_SHORT}-kv" --what-if
