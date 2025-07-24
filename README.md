# Multi-Organization GCP Log Forwarding to Google SecOps (Pub/Sub Method)

This repository contains Terraform configurations to facilitate the forwarding of Google Cloud Platform (GCP) logs from a Source Organization to a Google SecOps instance residing in a separate Destination Organization. This setup is ideal for centralizing security-relevant logs into a single SIEM for consolidated analysis and threat detection.

## Architecture
The architecture for this solution involves three main steps to securely transfer logs from the source GCP organization to the destination Google SecOps instance using Google Cloud Pub/Sub.

### Destination Organization (SecOps Org) - Step 1: Create Pub/Sub Topic

Logs from the source organization will be sent to a Pub/Sub topic created in a project within the Destination Organization. This topic acts as an intermediary for log ingestion into Google SecOps.

### Source Organization (GCP Org) - Step 2: Create Logging Sink
A logging sink is configured at the organization level in the Source Organization to export desired logs to the Pub/Sub topic created in Step 1. A service account (e.g., service-org-644818373504@gcp-sa-logging.iam.gserviceaccount.com) associated with this sink will publish messages to the destination topic.

### Destination Organization (SecOps Org) - Step 3: Create Pub/Sub Subscription and SecOps Feed Configuration
A Pub/Sub push subscription is created in the Destination Organization, configured to push logs from the topic to the Google SecOps ingestion endpoint. This subscription is authenticated using a dedicated service account and is granted necessary permissions like roles/pubsub.publisher, roles/pubsub.subscriber, and roles/chronicle.admin within the destination project. This step also explicitly grants the roles/pubsub.publisher permission to the source sink's writer identity from Step 2 on the destination project.

## 📋 Prerequisites
Before deploying this solution, ensure you have the following:

- Two separate Google Cloud Organizations (Source and Destination).

- A Google SecOps instance configured in the Destination Organization.

- Terraform installed and configured with appropriate GCP credentials.

- The Google Cloud Pub/Sub API enabled in the destination project.

## 🚀 Setup and Deployment
The deployment is broken down into three steps, corresponding to the architecture. Each step has its own Terraform directory.

<b>Step 1: Destination Org - Create Pub/Sub Topic</b>

This step sets up the Pub/Sub topic in your Google SecOps organization where logs will be received.

1. Navigate to the ```step1-dest/``` directory.

1. Update ```variables.auto.tfvars``` with your SecOps project ID:

    ```terraform
    secops_project_id = "arg-secops-457822"
    ```

1. Initialize Terraform:

    ```Bash
    terraform init && terraform plan
    ```

1. Apply the Terraform configuration:

    ```Bash
    terraform apply --auto-approve
    ```

This will create a Pub/Sub topic (e.g., secops-log-ingest-XXXX) and output its full name. 

<b>IMPORTANT: Make a note of this output as it's needed for Step 2.</b>

Example output format: ```projects/arg-secops-457822/topics/secops-log-ingest-4995```

<b>Step 2: Source Org - Create Logging Sink</b>

This step configures an organization-level logging sink in your source GCP organization to forward logs to the Pub/Sub topic created in Step 1.

1. Navigate to the ```step2-source``` directory.

1. Update ```variables.auto.tfvars``` with your organization details and the Pub/Sub topic name from Step 1:

    ```Terraform
    google_organization = "sfolabs.io"
    source_project_id = "secops-test-458320"
    dest_project_name = "arg-secops-457822"
    dest_pubsub_topic = "secops-log-ingest-4995"
    ```

1. Initialize Terraform:

    ```Bash
    terraform init && terraform plan
    ```

1. Apply the Terraform configuration:

    ```Bash
    terraform apply --auto-approve
    ```

This will create an organization-level logging sink and output the writer_identity service account. This service account will be granted roles/pubsub.publisher permissions on the destination Pub/Sub topic in Step 3.

Example output: 

```bash
Grant this SA the permission roles/pubsub.publisher in the Destination Org: serviceAccount:service-org-644818373504@gcp-sa-logging.iam.gserviceaccount.com
```

<b>Step 3: Destination Org - Create Pub/Sub Subscription and SecOps Feed Configuration</b>

This final step sets up the Pub/Sub subscription in the Destination Organization to push logs to your Google SecOps instance and grants the necessary cross-organization permissions.

1. Navigate to the working/step3-dest/ directory.

1. Update variables.auto.tfvars with the ```secops_project_id```, the ```secops_endpoint``` (from your Google SecOps feed configuration), the ```source_sink_sa``` (from Step 2's output), and the ```dest_pubsub_topic``` (from Step 1's output).

    ```Terraform
    secops_project_id = "arg-secops-457822"
    secops_endpoint = "YOUR_GOOGLE_SECOPS_FEED_ENDPOINT" # Get this from your Google SecOps instance (Settings -> Feeds -> Add New -> Google Cloud Pub/Sub -> Finalize tab)
    source_sink_sa = "serviceAccount:service-org-644818373504@gcp-sa-logging.iam.gserviceaccount.com" # Output from Step 2
    dest_pubsub_topic = "projects/arg-secops-457822/topics/secops-log-ingest-4995" # Output from Step 1
    ```
1. Initialize Terraform:

    ```Bash
    terraform init && terraform plan
    ```

1. Apply the Terraform configuration:

    ```Bash
    terraform apply --auto-approve
    ```

This step creates a dedicated service account (```secops-pubsub-pusher-XXXX```) for the Pub/Sub push subscription and grants it necessary roles (```roles/pubsub.publisher```, ```roles/pubsub.subscriber```, and ```roles/chronicle.admin```). 

It then creates the Pub/Sub subscription configured to push messages to the Google SecOps ingestion endpoint, using this new service account for authentication. 

It also explicitly grants the ```roles/pubsub.publisher``` permission to the ```source_sink_sa``` from Step 2 on the destination project (```var.secops_project_id```).

## 🧹 Cleanup

To destroy the created resources, navigate to each directory in reverse order (Step 3, then Step 2, then Step 1) and run:

```bash
terraform destroy
```

## Common Issues and Troubleshooting

1. **Permission Denied**: Ensure that Organization A has granted the correct IAM permissions to Organization B's service account.

2. **Topic Not Found**: Verify that the topic name and project ID from Organization A are correctly entered in Organization B's variables.

3. **Subscription Creation Fails**: This usually indicates a permission issue. Check that:
   - The service account email is correct
   - The IAM binding was correctly applied in Organization A
   - Organization B's service account has the necessary roles/pubsub.subscriber permission

4. **Logs Not Appearing in SecOps**: Verify:
   - The log sink in Organization A is correctly filtering and exporting logs
   - The push subscription in Organization B is correctly configured with the SecOps endpoint
   - The service account has the roles/chronicle.ingestionServiceAgent permission

## Monitoring the Setup

- Check the Pub/Sub subscription metrics in the Google Cloud Console to ensure messages are being delivered
- Look for acknowledgement metrics (ack_message_count) to confirm SecOps is receiving the messages
- Monitor the log sink export metrics to ensure logs are being exported properly