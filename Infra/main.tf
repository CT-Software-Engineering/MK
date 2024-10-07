provider "google" {
  project = var.project_id
  region  = var.region
}
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
}
resource "google_project_iam_member" "gke_service_account_roles" {
  for_each = toset([
    "roles/container.admin",
    "roles/compute.networkAdmin",
    "roles/compute.instanceAdmin.v1",
    "roles/compute.securityAdmin",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/logging.logWriter",
    "roles/logging.admin",
    "roles/monitoring.metricWriter",
    "roles/monitoring.admin",
    "roles/storage.admin",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/viewer",
    "roles/cloudsql.client",
    "roles/cloudsql.admin",
     "roles/cloudsql.editor",
     "roles/compute.admin"
    
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}
resource "google_service_account_key" "gke_service_account_key" {
  service_account_id = google_service_account.gke_service_account.name
}

# Output the service account email
output "gke_service_account_email" {
  value = google_service_account.gke_service_account.email
}

# Output the service account key (if created)
output "gke_service_account_key" {
  value     = google_service_account_key.gke_service_account_key.private_key
  sensitive = true
}

# # Enable Service Networking API
# resource "google_project_service" "service_networking" {
#   project    = var.project_id
#   service    = "servicenetworking.googleapis.com"
#   depends_on = [google_service_account.gke_service_account]

# }
# # Enable Compute Engine API  //decide if  you are going to enable this manually or not since the destroy can be an issue.
# resource "google_project_service" "compute" {
#   project    = var.project_id
#   service    = "compute.googleapis.com"
#   depends_on = [google_service_account.gke_service_account]
# }

# # Enable Container API
# resource "google_project_service" "container" {
#   project    = var.project_id
#   service    = "container.googleapis.com"
#   depends_on = [google_service_account.gke_service_account]
# }

resource "google_compute_instance" "jenkins-server" {
  name                      = "jenkins-server"
  machine_type              = "e2-medium"
  zone                      = "${var.region}-b"
  allow_stopping_for_update = true

  metadata = {
    "enable-serial-port" = "true"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.public_subnet.self_link

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = "gke-service-account@militaryknowledge.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/jenkins-startup-script.sh")

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [boot_disk, metadata_startup_script]
  }
}


resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING" # Correctly specify purpose
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id # Ensure this network exists
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
  network    = "${var.project_id}-vpc" # Ensure this matches your VPC name
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
  network    = "${var.project_id}-vpc" # Ensure this matches your VPC name
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
  network = var.vpc_name  # Reference your existing VPC

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]  # Change this to restrict access if needed

  //target_tags = ["your-target-tag"]  # Optional: specify target tags if applicable
}


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
resource "google_compute_firewall" "iap_allow_ssh" {
  name    = "allow-ssh-from-iap"
  network = google_compute_network.vpc.name # Ensure this is your VPC name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # IAP's IP range
  target_tags   = ["your-vm-tag"]     # Ensure you set the right network tag for your VM
}
