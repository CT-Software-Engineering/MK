resource "google_service_account" "jenkins_gke_deployer" {
  account_id   = "jenkins-gke-deployer"
  display_name = "Jenkins GKE Deployer"
  description  = "Service account for Jenkins to deploy to GKE"
}

resource "google_project_iam_member" "jenkins_gke_deployer_roles" {
  for_each = toset([
    "roles/container.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.jenkins_gke_deployer.email}"
}

resource "google_service_account_key" "jenkins_gke_deployer_key" {
  service_account_id = google_service_account.jenkins_gke_deployer.name
}

output "jenkins_gke_deployer_key" {
  value     = google_service_account_key.jenkins_gke_deployer_key.private_key
  sensitive = true
}
resource "google_project_iam_member" "service_account_viewer" {
  project = var.project_id
  role    = "roles/iam.serviceAccountViewer"
  member  = "serviceAccount:gke-service-account@militaryknowledge.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:gke-service-account@militaryknowledge.iam.gserviceaccount.com"
}