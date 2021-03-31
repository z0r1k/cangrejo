# Interface

variable "aiven_api_token" {}

variable "aiven_project_name" {}
variable "stage_name" {}
variable "cloud_name" {}
variable "plan" {}

variable "dest_metrics_service" {}

# Provider

terraform {
  required_providers {
    aiven = {
      source = "aiven/aiven"
      version = "2.1.9"
    }
  }
}

provider "aiven" {
  api_token = var.aiven_api_token
}

# PostreSQL
resource "aiven_service" "db" {
  project                 = var.aiven_project_name
  cloud_name              = var.cloud_name
  plan                    = var.plan
  service_name            = var.stage_name
  service_type            = "pg"
  maintenance_window_dow  = "friday"
  maintenance_window_time = "20:00:00"

  pg_user_config {
    pg {
      idle_in_transaction_session_timeout = 900
    }
    pg_version = "13"
  }
}

resource "aiven_database" "crab_db" {
  project       = var.aiven_project_name
  service_name  = aiven_service.db.service_name
  database_name = "stock"
}

resource "aiven_service_user" "user" {
  project      = var.aiven_project_name
  service_name = aiven_service.db.service_name
  username     = "crab"
}

resource "aiven_connection_pool" "conn_pool" {
  project       = var.aiven_project_name
  service_name  = aiven_service.db.service_name
  database_name = aiven_database.crab_db.database_name
  pool_name     = "pool"
  username      = aiven_service_user.user.username
}

resource "aiven_service_integration" "pg_metrics" {
  project                  = var.aiven_project_name
  integration_type         = "metrics"
  source_service_name      = aiven_service.db.service_name
  destination_service_name = var.dest_metrics_service
}

output "service_uri" {
  value = aiven_service.db.service_uri
}
