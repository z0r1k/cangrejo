variable "aiven_api_token" {
  description = "Aiven API token"
  type        = string
}

variable "aiven_project_name" {
  description = "Project Name"
  type        = string
}

variable "cloud_name" {
  description = "Cloud Provider"
  type        = string
}

variable "plan" {
  description = "Aiven Plan"
  type        = string
}

variable "kafka_stage_name" {
  description = "Kafka Environment"
  type        = string
}

variable "kafka_version" {
  description = "Kafka Version"
  type        = string
}

variable "kafka_connect" {
  description = "Kafka Connect"
  type        = bool
}

variable "kafka_rest" {
  description = "Kafka REST"
  type        = bool
}

variable "kafka_schema_registry" {
  description = "Kafka Schema Registry"
  type        = bool
}

variable "log_retention_bytes" {
  description = "Kafka Log Retention in Bytes"
  type        =  number
}

variable "log_retention_hours" {
  description = "Kafka Log Retention in Hours"
  type        =  number
}

variable "prometheus_endpoint_user" {
  description = "Prometheus Endpoint Username"
  type        = string
}

variable "prometheus_endpoint_name" {
  description = "Prometheus Endpoint Name"
  type        = string
}

variable "grafana_stage_name" {
  description = "Grafana Environment"
  type        = string
}

variable "influx_stage_name" {
  description = "Influx Environment"
  type        = string
}

variable "pg_stage_name" {
  description = "Postgres Environment"
  type        = string
}
