output "gitlab_instance_ip" {
  description = "The external IP address of the GitLab server"
  value       = google_compute_instance.gitlab_instance.network_interface[0].access_config[0].nat_ip
}