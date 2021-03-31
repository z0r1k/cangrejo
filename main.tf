module "metrics" {
  source             = "./modules/influx"
  aiven_api_token    = var.aiven_api_token
  aiven_project_name = var.aiven_project_name
  stage_name         = var.influx_stage_name
  cloud_name         = var.cloud_name
  plan               = var.plan
}

output "influx_service_uri" {
  value = module.metrics.service_uri
}

module "db" {
  source                = "./modules/postgres"
  aiven_api_token       = var.aiven_api_token
  aiven_project_name    = var.aiven_project_name
  stage_name            = var.pg_stage_name
  cloud_name            = var.cloud_name
  plan                  = var.plan
  dest_metrics_service  = module.metrics.service_name
}

output "pg_service_uri" {
  value = module.db.service_uri
}

module "broker" {
  source                   = "./modules/kafka"
  aiven_api_token          = var.aiven_api_token
  aiven_project_name       = var.aiven_project_name
  stage_name               = var.kafka_stage_name
  cloud_name               = var.cloud_name
  plan                     = "business-4"
  kafka_version            = var.kafka_version
  kafka_connect            = var.kafka_connect
  kafka_rest               = var.kafka_rest
  kafka_schema_registry    = var.kafka_schema_registry
  log_retention_bytes      = var.log_retention_bytes
  log_retention_hours      = var.log_retention_hours
  prometheus_endpoint_user = var.prometheus_endpoint_user
  prometheus_endpoint_name = var.prometheus_endpoint_name
  dest_metrics_service     = module.metrics.service_name
}

output "kafka_service_uri" {
  value = module.broker.service_uri
}

module "dashboard" {
  source               = "./modules/grafana"
  aiven_api_token      = var.aiven_api_token
  aiven_project_name   = var.aiven_project_name
  stage_name           = var.grafana_stage_name
  cloud_name           = var.cloud_name
  plan                 = var.plan
  dest_metrics_service = module.metrics.service_name
}

output "grafana_service_uri" {
  value = module.dashboard.service_uri
}
