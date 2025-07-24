

data "google_project" "project" {
project_id = var.secops_project_id
}

resource "random_integer" "rand" {
  min = 1000
  max = 5000
}

# Enable the Pub/Sub API
resource "google_project_service" "pubsub_api" {
  project = data.google_project.project.id # Replace with your project ID
  service = "pubsub.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = true
}

# Create a Pub/Sub topic in the destination project
resource "google_pubsub_topic" "log_topic" {
  name    = "secops-log-ingest-${random_integer.rand.result}"
  project = var.secops_project_id
}

output "dest_pubsub_topic" {
  value = "projects/${var.secops_project_id}/topics/${google_pubsub_topic.log_topic.name}"
  description = "The name of the Dest Pub/Sub topic (share with Source Org)"
}