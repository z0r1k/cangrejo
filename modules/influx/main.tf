# Interface

variable "aiven_api_token" {}

variable "aiven_project_name" {}
variable "stage_name" {}
variable "cloud_name" {}
variable "plan" {}

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

# InfluxDB service
resource "aiven_service" "influxdb-metrics" {
  project                 = var.aiven_project_name
  cloud_name              = var.cloud_name
  plan                    = var.plan
  service_name            = var.stage_name
  service_type            = "influxdb"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "11:00:00"

  influxdb_user_config {
    ip_filter = ["0.0.0.0/0"]
  }
}


output "service_name" {
  value = aiven_service.influxdb-metrics.service_name
}

output "service_uri" {
  value = aiven_service.influxdb-metrics.service_uri
}
