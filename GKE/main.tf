# Create the GKE cluster
resource "google_container_cluster" "gke_cluster" {
  name                = var.cluster_name
  project             = var.project_id
  location            = var.zone    // Change to region if you want to have a minimum of 3 nodes
  network             = var.vpc_name
  subnetwork          = var.private_subnet
  deletion_protection = false

  initial_node_count = 1

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "my-node-pool"
  location   = var.zone # Change to region will give you 6 nodes
  cluster    = google_container_cluster.gke_cluster.name

  # Enable autoscaling
  autoscaling {
    min_node_count = 1      # Minimum number of nodes
    max_node_count = 5      # Maximum number of nodes
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 20
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    preemptible     = true
    service_account = "gke-service-account@militaryknowledge.iam.gserviceaccount.com"
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# Data source for client configuration
data "google_client_config" "default" {}

# Output for kubeconfig
output "kubeconfig" {
  value = {
    cluster_name           = google_container_cluster.gke_cluster.name
    endpoint               = google_container_cluster.gke_cluster.endpoint
    client_certificate     = base64decode(google_container_cluster.gke_cluster.master_auth[0].client_certificate)
    client_key             = base64decode(google_container_cluster.gke_cluster.master_auth[0].client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
  sensitive = true
}

# Output for the GKE cluster endpoint
output "cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}