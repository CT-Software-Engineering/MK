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
  project    = var.project_id
  name       = var.nat_router
  network    = google_compute_network.vpc.self_link
  region     = var.region
  depends_on = [google_compute_network.vpc]
}


resource "google_compute_router_nat" "nat" {
  name                               = var.my_nat_gateway
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on                         = [google_compute_router.router]

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING" # Correctly specify purpose
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]


}

resource "google_compute_firewall" "gke_to_jenkins" {
  name       = "allow-gke-to-jenkins"
  network    = google_compute_network.vpc.name
  depends_on = [google_compute_network.vpc]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["jenkins"]
}


# Firewall rule for IPv4
resource "google_compute_firewall" "allow_jenkins_gitlab_ipv4" {
  name       = "allow-jenkins-gitlab-ipv4"
  network    = google_compute_network.vpc.name
  depends_on = [google_compute_network.vpc]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]

  description = "Allow Jenkins and GitLab traffic on port 8080 for IPv4."
}

# Firewall rule for IPv6
resource "google_compute_firewall" "allow_jenkins_gitlab_ipv6" {
  name       = "allow-jenkins-gitlab-ipv6"
  network    = google_compute_network.vpc.name
  depends_on = [google_compute_network.vpc]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["::/0"]

  description = "Allow Jenkins and GitLab traffic on port 8080 for IPv6."
}

# resource "google_compute_firewall" "allow_ssh" {
#   name    = "allow-ssh"
#   network = google_compute_network.militaryknowledge_vpc.name

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   source_ranges = ["0.0.0.0/0"]
# }
resource "google_compute_firewall" "allow_ssl" {
  name    = "allow-ssl"
  network = google_compute_network.vpc.self_link


  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"] # Change this to restrict access if needed
  depends_on    = [google_compute_network.vpc]
}
//target_tags = ["your-target-tag"]  # Optional: specify target tags if applicable



resource "google_project_service" "disable_container" {
  project                    = var.project_id
  service                    = "container.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
  depends_on                 = [google_service_account.gke_service_account]
}

# resource "google_project_service" "disable_compute" {
#   project                    = var.project_id
#   service                    = "compute.googleapis.com"
#   disable_on_destroy         = true
#   disable_dependent_services = true
#   depends_on                 = [google_service_account.gke_service_account]
# }
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-ssh-from-iap"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # IAP's IP range
  target_tags   = ["jenkins"]         # Ensure you set the right network tag for your VM
}