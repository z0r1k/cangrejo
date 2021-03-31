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

# Grafana service
resource "aiven_grafana" "grafana" {
  project      = var.aiven_project_name
  cloud_name   = var.cloud_name
  plan         = var.plan
  service_name = var.stage_name
  maintenance_window_dow = "monday"
  maintenance_window_time = "10:00:00"

  grafana_user_config {
    ip_filter = ["0.0.0.0/0"]
    alerting_enabled = true

    public_access {
      grafana = true
    }
  }
}

# Dashboards for Kafka and PostgreSQL services
resource "aiven_service_integration" "grafana_dashboards" {
  project                  = var.aiven_project_name
  integration_type         = "dashboard"
  source_service_name      = aiven_grafana.grafana.service_name
  destination_service_name = var.dest_metrics_service
}

output "service_uri" {
  value = aiven_grafana.grafana.service_uri
}
