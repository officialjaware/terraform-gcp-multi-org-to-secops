
/**data "google_project" "project" {
  project_id = var.source_project_id
}**/

data "google_organization" "org" {
  domain = var.google_organization
}

resource "random_integer" "rand" {
  min = 1000
  max = 5000
}
/**
resource "google_logging_project_sink" "source_sink" {
  name = "source-sink-${random_integer.rand.result}"

  destination = "pubsub.googleapis.com/projects/${var.dest_project_name}/topics/${var.dest_pubsub_topic}"

}**/

resource "google_logging_organization_sink" "source_sink" {
  name   = "source-sink-${random_integer.rand.result}"
  org_id = data.google_organization.org.org_id

  # Can export to pubsub, cloud storage, or bigquery
  destination = "pubsub.googleapis.com/projects/${var.dest_project_name}/topics/${var.dest_pubsub_topic}"

  # Log all WARN or higher severity messages relating to instances
  #filter = "resource.type = gce_instance AND severity >= WARNING"
}

/**
output "source_sink_sa" {
  value = "Grant this SA the permission roles/pubsub.publisher in the Destination Org: ${google_logging_project_sink.source_sink.writer_identity}"
}
**/
 
output "source_sink_sa" {
  value = "Grant this SA the permission roles/pubsub.publisher in the Destination Org: ${google_logging_organization_sink.source_sink.writer_identity}"
}