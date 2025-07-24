# Variables
variable "secops_project_id" {
  description = "The project ID where Google SecOps is configured (e.g., chronicle-secops)"
  type        = string
}

variable "secops_endpoint" {
  type = string
}

variable "source_sink_sa" {
  type = string
}

variable "dest_pubsub_topic" {
  type = string
}