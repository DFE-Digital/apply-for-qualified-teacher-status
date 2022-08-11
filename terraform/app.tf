locals {
  azure_environment_variables = try(yamldecode(
    data.azurerm_key_vault_secret.secrets["APPLY-QTS-APP-VARIABLES"].value
  ), {})

  app_environment_variables = merge(local.azure_environment_variables, local.app_config, {
    HOSTING_ENVIRONMENT = var.environment_name,
    REDIS_URL           = cloudfoundry_service_key.redis_key.credentials.uri,

    BIGQUERY_PROJECT_ID = local.bigquery_project_id,
    BIGQUERY_DATASET    = local.bigquery_dataset,
    BIGQUERY_TABLE_NAME = local.bigquery_table_name,

    RAILS_SERVE_STATIC_FILES = "true"

    AZURE_STORAGE_ACCOUNT_NAME = azurerm_storage_account.forms.name,
    AZURE_STORAGE_ACCESS_KEY   = azurerm_storage_account.forms.primary_access_key,
    AZURE_STORAGE_CONTAINER    = azurerm_storage_container.uploads.name
  })
  logstash_endpoint = data.azurerm_key_vault_secret.secrets["LOGSTASH-ENDPOINT"].value
}

resource "cloudfoundry_route" "apply_qts_public" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = local.apply_qts_app_name
  space    = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_route" "apply_qts_internal" {
  count    = local.configure_prometheus_network_policy
  domain   = data.cloudfoundry_domain.internal.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.apply_qts_app_name
}

resource "cloudfoundry_route" "education" {
  for_each = toset(var.education_hostnames)

  domain   = data.cloudfoundry_domain.education.id
  hostname = each.value
  space    = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_user_provided_service" "logging" {
  name             = local.logging_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = "syslog-tls://${local.logstash_endpoint}"
}

resource "cloudfoundry_app" "app" {
  name         = local.apply_qts_app_name
  space        = data.cloudfoundry_space.space.id
  instances    = var.apply_qts_instances
  memory       = var.apply_qts_memory
  disk_quota   = var.apply_qts_disk_quota
  docker_image = var.apply_qts_docker_image
  strategy     = "blue-green"
  environment  = local.app_environment_variables

  health_check_type          = "http"
  health_check_http_endpoint = "/healthcheck"

  dynamic "routes" {
    for_each = local.apply_qts_routes
    content {
      route = routes.value.id
    }
  }

  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
    }
  }
}

resource "cloudfoundry_app" "worker" {
  name         = "${local.apply_qts_app_name}-worker"
  space        = data.cloudfoundry_space.space.id
  instances    = var.apply_qts_instances
  memory       = var.apply_qts_memory
  disk_quota   = var.apply_qts_disk_quota
  docker_image = var.apply_qts_docker_image
  command      = "bundle exec sidekiq -C ./config/sidekiq.yml"
  strategy     = "blue-green"
  environment  = local.app_environment_variables

  health_check_type = "process"

  service_binding {
    service_instance = cloudfoundry_service_instance.postgres.id
  }

  service_binding {
    service_instance = cloudfoundry_service_instance.redis.id
  }
}

resource "cloudfoundry_service_instance" "postgres" {
  name         = local.postgres_database_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_database_service_plan]
  json_params  = jsonencode(local.restore_db_backup_params)
  timeouts {
    create = "60m"
    update = "60m"
  }
}

resource "cloudfoundry_service_instance" "redis" {
  name         = local.redis_database_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_service_plan]
}

resource "cloudfoundry_service_key" "redis_key" {
  name             = "${local.redis_database_name}_key"
  service_instance = cloudfoundry_service_instance.redis.id
}
