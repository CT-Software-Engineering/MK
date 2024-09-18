# Declare the static IP for the NAT gateway
resource "google_compute_address" "nat_ip" {
  name   = "nat-ip"
  region = var.region
}

# Create the GKE cluster
resource "google_container_cluster" "gke_cluster" {
  name               = "militaryknowledge-cluster"
  location           = var.region
  network            = var.vpc_name
  subnetwork         = var.private_subnet

  remove_default_node_pool = true

  node_pool {
    name       = "custom-node-pool"
    node_count = 1

    node_config {
      machine_type = var.machine_type
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

# Create the NAT router
resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  region  = var.region
  network = var.vpc_name
}

# Configure the NAT gateway
resource "google_compute_router_nat" "nat_gateway" {
  name                   = "nat-gateway"
  router                 = google_compute_router.nat_router.name
  region                 = google_compute_router.nat_router.region
  nat_ip_allocate_option  = "MANUAL_ONLY"

  nat_ips                = ["146.148.5.132"]
  

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  depends_on = [
    google_compute_address.nat_ip,
    google_compute_router.nat_router
  ]

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Output for the NAT IP address
output "nat_ip" {
  value = google_compute_address.nat_ip.address
}

# Output for the GKE cluster endpoint
output "cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}