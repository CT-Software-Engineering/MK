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

#use this option to secure that egress is only used for ssh to self hosted gitlab
# resource "google_compute_firewall" "allow_gitlab_ssh" {
#   name    = "allow-jenkins-to-gitlab-ssh"
#   network = google_compute_network.vpc.name

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   direction          = "EGRESS"
#   destination_ranges = ["10.110.2.170]/32"]  # Replace with GitLab server's IP
#   target_tags        = ["jenkins"]
# }
