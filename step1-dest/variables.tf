# Variables
variable "secops_project_id" {
  description = "The project ID where Google SecOps is configured (e.g., chronicle-secops)"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}