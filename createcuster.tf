resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_project_iam_member" "allow_image_pull" {
  project = "changeme"
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${var.service_account_email}"
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "us-central1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}