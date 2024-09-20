# provider.tf
provider "google" {
  project = var.project_id
  region  = var.region

}

resource "google_compute_instance" "jenkins-server" {
  name         = "jenkins-server"
  machine_type = "e2-medium"
  zone         = "${var.region}-b"
  metadata = {
    ssh-keys = <<EOT
dimitri_griparis:ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPExVMMv6aaz81NER4Azb0YKFpWrB7Dlx+XXd2QXgNZMQDViiHx1hP7/hkAeDVcm9LZJnj32iZ/ZwIj06fmlS0I= google-ssh {"userName":"<a href="mailto:dimitri.griparis@ctengineeringgroup.com">dimitri.griparis@ctengineeringgroup.com</a>","expireOn":"2024-09-17T05:16:13+0000"}
dimitri_griparis:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAH91lKndprKXRXzqt9mdO15H4WbS58+o6YPWdNlme//kBL+m53SBaM5P69syqWb6rnld6REMc1y4pSafTUuS3ppl2I73fBHXPPmXASjm/5POeWaBr8rshWM2BFQOEmv4jMzaViUaA8p+0ET3ZfdcAxD8Lnyh0Mn/2u4AAHUaIESbNHS6xJuJUMyzVatPa4VOK6i3COcUwXJCWS3RWkkXW5RajYls3RY3h3h41I2hqWfHcrV3mPBi/KfB+RItCnqInkY3Vb8v/j7lt+YT6Ni7usjLbwNPukgRPI7zdpozlFI82uJtDAK6lJPGh6XFyL45XlTGoMpU14jwBzGW+T3mx9U= google-ssh {"userName":"<a href="mailto:dimitri.griparis@ctengineeringgroup.com">dimitri.griparis@ctengineeringgroup.com</a>","expireOn":"2024-09-17T05:16:16+0000"}
EOT
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

  tags = ["jenkins"]

  # service_account {
  #   email  = "militaryknowledge@appspot.gserviceaccount.com"
  #   scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  # }

  metadata_startup_script = file("jenkins-startup-script.sh")

  lifecycle {
    prevent_destroy = false
    ignore_changes = [metadata,]
  }
}
# Create the service account
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
  description  = "Service account for GKE with access to services and VPC"
}

# Assign necessary roles to the service account
resource "google_project_iam_member" "gke_service_account_roles" {
 for_each = toset([
    "roles/container.admin",         # Full access to GKE
    "roles/compute.networkAdmin",    # Full access to VPC and subnets (upgraded from networkUser)
    "roles/iam.serviceAccountUser",  # Ability to use service accounts
    "roles/logging.logWriter",       # Write logs
    "roles/monitoring.metricWriter", # Write metrics
    "roles/storage.admin",           # Full access to GCS (upgraded from objectViewer)
    "roles/stackdriver.resourceMetadata.writer" # Write resource metadata to Stackdriver
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# Optional: Create a key for the service account
# Note: It's generally better to use Workload Identity instead of keys
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
resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"

  disable_on_destroy = false
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.servicenetworking]
}

resource "google_compute_firewall" "gke_to_jenkins" {
  #count   = 1  # Set this to 0 if you want to disable the rule temporarily
  name    = "allow-gke-to-jenkins"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  # This is a placeholder CIDR range. Update this when your GKE cluster is created.
  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["jenkins"]
}

# Enable Service Networking API
resource "google_project_service" "service_networking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"

  disable_on_destroy = false
}

# Enable Compute Engine API (if not already enabled)
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

# Enable Container API (for GKE)
resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"

  disable_on_destroy = false
}
