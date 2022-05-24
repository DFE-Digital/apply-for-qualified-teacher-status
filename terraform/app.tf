locals {
  app_environment_variables = try(local.application_environment_variables, null)
}

resource "cloudfoundry_route" "apply_qts_public" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = local.apply_qts_app_name
  space    = data.cloudfoundry_space.space.id
}
resource "cloudfoundry_app" "app" {
  name                       = local.apply_qts_app_name
  space                      = data.cloudfoundry_space.space.id
  instances                  = var.apply_qts_instances
  memory                     = var.apply_qts_memory
  disk_quota                 = var.apply_qts_disk_quota
  docker_image               = var.apply_qts_docker_image
  strategy                   = "blue-green"
  environment                = local.app_environment_variables
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
