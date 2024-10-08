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

# Enable Service Networking API
resource "google_project_service" "service_networking" {
  project    = var.project_id
  service    = "servicenetworking.googleapis.com"
  depends_on = [google_service_account.gke_service_account]
}

# Enable Compute Engine API
resource "google_project_service" "compute" {
  project    = var.project_id
  service    = "compute.googleapis.com"
  depends_on = [google_service_account.gke_service_account]
}

# Enable Container API
resource "google_project_service" "container" {
  project    = var.project_id
  service    = "container.googleapis.com"
  depends_on = [google_service_account.gke_service_account]
}

resource "google_compute_instance" "jenkins-server" {
  name                      = "jenkins-server"
  machine_type              = "e2-medium"
  zone                      = "${var.region}-b"
  allow_stopping_for_update = true
  tags                      = ["jenkins"]

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
    email  = google_service_account.gke_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/jenkins-startup-script.sh")

  lifecycle {
    prevent_destroy = false
    //ignore_changes  = [boot_disk, metadata_startup_script]
  }

  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.public_subnet
  ]
}
