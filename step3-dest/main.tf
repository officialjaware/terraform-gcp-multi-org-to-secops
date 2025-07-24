

resource "random_integer" "rand" {
  min = 1000
  max = 5000
}

# Create a service account for the push subscription authentication
resource "google_service_account" "secops_pubsub_sa" {
  account_id   = "secops-pubsub-pusher-${random_integer.rand.result}"
  display_name = "Service Account for SecOps Pub/Sub push subscription"
  project      = var.secops_project_id
}

resource "google_project_iam_member" "secops_sa_pubsub" {
  project = var.secops_project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.secops_pubsub_sa.email}"
}

resource "google_project_iam_member" "secops_sa_pubsub2" {
  project = var.secops_project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.secops_pubsub_sa.email}"
}

resource "google_project_iam_member" "secops_sa_secops" {
  project = var.secops_project_id
  role    = "roles/chronicle.admin"
  member  = "serviceAccount:${google_service_account.secops_pubsub_sa.email}"
}

resource "google_project_iam_member" "source_sink_sa" {
  project = var.secops_project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${var.source_sink_sa}"
}

resource "google_pubsub_subscription" "secops_subscription" {
  name    = "secops-log-ingest-sub-${random_integer.rand.result}"
  project = var.secops_project_id
  
  # Reference to the topic in Dest Org created in Step 1
  topic = var.dest_pubsub_topic

  # Configure as push subscription to SecOps
  push_config {
    push_endpoint = var.secops_endpoint
    
    # Set proper OIDC token for authentication
    oidc_token {
      service_account_email = google_service_account.secops_pubsub_sa.email
    }
    
    # Set content type as required by SecOps
    attributes = {
      "content-type" = "application/json"
    }
  }

  # Adjust based on your requirements
  message_retention_duration = "604800s"  # 7 days
  retain_acked_messages      = false
  ack_deadline_seconds       = 20
  
}