# Variables
variable "google_organization" {
  type = string
}

variable "source_project_id" {
  type = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "dest_pubsub_topic" {
  type = string
}

variable "dest_project_name" {
  type = string
}