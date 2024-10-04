terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.5"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
}
provider "kubernetes" {
  host                   = "https://${google_container_cluster.your_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.your_cluster.master_auth[0].cluster_ca_certificate)
}