locals {
  azure_environment_variables = try(yamldecode(
    data.azurerm_key_vault_secret.secrets["APPLY-QTS-APP-VARIABLES"].value
  ), {})

  app_environment_variables = merge(local.azure_environment_variables, {
    HOSTING_ENVIRONMENT = var.environment_name,
    REDIS_URL           = cloudfoundry_service_key.redis_key.credentials.uri,

    BIGQUERY_PROJECT_ID = local.bigquery_project_id,
    BIGQUERY_DATASET    = local.bigquery_dataset,
    BIGQUERY_TABLE_NAME = local.bigquery_table_name
  })
}

resource "cloudfoundry_route" "apply_qts_public" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = local.apply_qts_app_name
  space    = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_route" "education" {
  for_each = toset(var.education_hostnames)

  domain   = data.cloudfoundry_domain.education.id
  hostname = each.value
  space    = data.cloudfoundry_space.space.id
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

  service_binding {
    service_instance = cloudfoundry_service_instance.postgres.id
  }

  service_binding {
    service_instance = cloudfoundry_service_instance.redis.id
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
