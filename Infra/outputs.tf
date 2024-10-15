
output "vpc_name" {
  value       = google_compute_network.vpc.name
  description = "The name of the VPC being created"
}

output "public_subnet_name" {
  value = google_compute_subnetwork.public_subnet.name
}

output "private_subnet_name" {
  value = google_compute_subnetwork.private_subnet.name
}



output "project_id" {
  value       = var.project_id
  description = "The ID of the GCP project"
}

output "region" {
  value       = var.region
  description = "The region in which resources are created"
}
# output "jenkins_server_ip" {
#   value       = google_compute_instance.jenkins-server.network_interface[0].access_config[0].nat_ip
#   description = "The public IP address of the Jenkins server"
# }
output "vpc_id" {
  value = google_compute_network.vpc.id
}
output "private_subnet_id" {
  value = google_compute_subnetwork.private_subnet.id
}

output "private_subnet_cidr" {
  value = google_compute_subnetwork.private_subnet.ip_cidr_range
}

