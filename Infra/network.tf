resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"

}

resource "google_compute_subnetwork" "public_subnet" {
  name                     = "${var.project_id}-public-subnet"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = "10.0.1.0/24"
  private_ip_google_access = true


  purpose = "PRIVATE"

}
resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.project_id}-private-subnet"
  ip_cidr_range = "10.0.2.0/24" # Adjust this CIDR range as needed
  region        = var.region
  network       = google_compute_network.vpc.id

  private_ip_google_access = true

  purpose = "PRIVATE"

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.1.0.0/16" # Adjust as needed
  }

  secondary_ip_range {
    range_name    = "service-range"
    ip_cidr_range = "10.2.0.0/16" # Adjust as needed
  }
}



resource "google_compute_firewall" "jenkins_firewall" {
  name    = "allow-jenkins"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins"]

}
locals {
  subnet_tags = {
    public  = "PUBLIC"
    private = "PRIVATE"
  }
}

resource "google_compute_firewall" "allow_egress" {
  name    = "allow-jenkins-egress"
  network = google_compute_network.vpc.name

  allow {
    protocol = "all"
  }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["jenkins"]
}

## Create Cloud Router

resource "google_compute_router" "router" {
  project = var.project_id
  name    = var.nat_router
  network = var.vpc_name
  region  = var.region
}

## Create Nat Gateway

resource "google_compute_router_nat" "nat" {
  name                               = var.my_nat_gateway
  router                             = var.nat_router
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
