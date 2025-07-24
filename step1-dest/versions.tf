# Provider configuration
provider "google" {
  project = var.secops_project_id
  region  = var.region
}