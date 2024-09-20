# Create the GKE cluster
resource "google_container_cluster" "gke_cluster" {
  name               = "militaryknowledge-cluster"
  location           = var.region
  network            = var.vpc_name
  subnetwork         = var.private_subnet
  deletion_protection = false

 remove_default_node_pool = true
 initial_node_count = 1

 node_locations = [var.zone]

  node_pool {
    name       = "custom-node-pool"
    node_count = 1
 autoscaling {
    min_node_count = 1
    max_node_count = 1
  }
    node_config {
      machine_type = var.machine_type
      service_account = "gke-service-account@militaryknowledge.iam.gserviceaccount.com"
      oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }
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
