# Interface

variable "aiven_api_token" {}

variable "aiven_project_name" {}
variable "stage_name" {}
variable "cloud_name" {}
variable "plan" {}

variable "dest_metrics_service" {}

variable "kafka_version" {
  default = "2.4"
}

variable "kafka_connect" {
  type    = bool
  default = false
}

variable "kafka_rest" {
  type    = bool
  default = false
}

variable "kafka_schema_registry" {
  type    = bool
  default = false
}

variable "log_retention_bytes" {
  type    = number
  default = 93000000000
}

variable "log_retention_hours" {
  type    = number
  default = 24
}

variable "prometheus_endpoint_user" {
  default = "prometheus"
}

variable "prometheus_endpoint_name" {
  default = "Prometheus Dev"
}

resource "random_password" "prometheus_endpoint_password" {
  length           = 16
  special          = true
  override_special = "!-._~"
}

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

# Broker

resource "aiven_kafka" "kafka" {
  project                 = var.aiven_project_name
  cloud_name              = var.cloud_name
  service_name            = var.stage_name
  maintenance_window_dow  = "wednesday"
  maintenance_window_time = "18:30:00"
  plan                    = var.plan
  termination_protection  = false

  kafka_user_config {
    kafka_version   = var.kafka_version
    kafka_connect   = var.kafka_connect
    kafka_rest      = var.kafka_rest
    schema_registry = var.kafka_schema_registry

    # More configuration could be found here:
    # https://github.com/aiven/terraform-provider-aiven/blob/master/aiven/templates/service_user_config_schema.json
    kafka {
      # Enable auto creation of topics
      auto_create_topics_enable = false

      # Number of partitions for autocreated topics
      num_partitions = 10

      # Replication factor for autocreated topics
      default_replication_factor = 2

      # The maximum size of message that the server can receive.
      message_max_bytes = 131072

      # The minimum allowed session timeout for registered consumers.
      # heartbeat.interval.ms is set to 3000 by default
      group_min_session_timeout_ms = 6000

      # The maximum allowed session timeout for registered consumers.
      # Longer timeouts give consumers more time to process messages in between heartbeats at the cost of a longer time to detect failures.
      group_max_session_timeout_ms = 300000

      # The maximum size of the log before deleting messages
      log_retention_bytes = var.log_retention_bytes

      # The number of hours to keep a log file before deleting it
      log_retention_hours = var.log_retention_hours

      # The maximum size of a single log file. Must be larger than any single message.
      log_segment_bytes = 1073741824

      # The number of bytes of messages to attempt to fetch for each partition (defaults to 1048576). This is not an absolute maximum,
      # if the first record batch in the first non-empty partition of the fetch is larger than this value, the record batch will still
      # be returned to ensure that progress can be made.
      replica_fetch_max_bytes = 1048576
    }

    public_access {
      kafka_rest = var.kafka_rest
      kafka_connect = var.kafka_connect
    }
  }
}

# Kafka topics smoke test
resource "aiven_kafka_topic" "ping" {
  project         = var.aiven_project_name
  service_name    = aiven_kafka.kafka.service_name
  topic_name      = "__ping__"
  partitions      = 10
  replication     = 2
  termination_protection = true

  config {
    # 24 hours
    retention_ms = 86400000
    retention_bytes = 1073741824
    cleanup_policy = "compact,delete"
  }
}

# Users for Kafka
resource "aiven_service_user" "admin" {
  project      = var.aiven_project_name
  service_name = aiven_kafka.kafka.service_name
  username     = "admin"
}
# Robot user
resource "aiven_service_user" "pipelines" {
  project      = var.aiven_project_name
  service_name = aiven_kafka.kafka.service_name
  username     = "pipelines"
}

# ACLs for Kafka
resource "aiven_kafka_acl" "admin" {
  project      = var.aiven_project_name
  service_name = aiven_kafka.kafka.service_name
  username     = aiven_service_user.admin.username
  permission   = "admin"
  topic        = "*"
}
# Dev cluster only
resource "aiven_kafka_acl" "ci" {
  project      = var.aiven_project_name
  service_name = aiven_kafka.kafka.service_name
  username     = aiven_service_user.pipelines.username
  permission   = "readwrite"
  topic        = aiven_kafka_topic.ping.topic_name
}

# Send metrics from Kafka to InfluxDB
resource "aiven_service_integration" "influx_kafka_metrics" {
  project                  = var.aiven_project_name
  integration_type         = "metrics"
  source_service_name      = aiven_kafka.kafka.service_name
  destination_service_name = var.dest_metrics_service
}

# Send metrics from Kafka to Prometheus
# https://github.com/aiven/terraform-provider-aiven/blob/master/aiven/templates/integration_endpoints_user_config_schema.json
resource "aiven_service_integration_endpoint" "prometheus" {
  project       = var.aiven_project_name
  endpoint_name = var.prometheus_endpoint_name
  endpoint_type = "prometheus"
  prometheus_user_config {
    basic_auth_username = var.prometheus_endpoint_user
    basic_auth_password = random_password.prometheus_endpoint_password.result
  }
}
resource "aiven_service_integration" "prometheus_kafka_metrics" {
  project                  = var.aiven_project_name
  integration_type         = "prometheus"
  destination_endpoint_id  = aiven_service_integration_endpoint.prometheus.id
  destination_service_name = ""
  source_endpoint_id       = ""
  source_service_name      = aiven_kafka.kafka.service_name
}

output "service_uri" {
  value = aiven_kafka.kafka.service_uri
}
