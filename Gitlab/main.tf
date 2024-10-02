provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Create a firewall rule to allow HTTPS and SSH traffic
resource "google_compute_firewall" "gitlab_firewall" {
  name    = "${var.gitlab_instance_name}-firewall"
  project = var.project_id
  network = var.vpc_name # Change this if using a custom VPC

  allow {
    protocol = "tcp"
    ports    = ["22", "443"] # Allow SSH, HTTPS
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create a persistent disk for GitLab
resource "google_compute_disk" "gitlab_disk" {
  name = "${var.gitlab_instance_name}-disk"
  type = "pd-standard"
  zone = var.zone
  size = var.gitlab_disk_size
}

# Create a GCE instance for GitLab
resource "google_compute_instance" "gitlab" {
  name         = var.gitlab_instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20210927" # Ubuntu 20.04 LTS
      size  = var.gitlab_disk_size
    }
  }

  attached_disk {
    source = google_compute_disk.gitlab_disk.id
  }

  network_interface {
    subnetwork = var.private_subnet # Specify your subnetwork here
    access_config {
      // Use an ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y curl openssh-server ca-certificates tzdata
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
    sudo apt-get install -y gitlab-ee
  EOF
}

resource "null_resource" "update_gitlab_url" {
  depends_on = [google_compute_instance.gitlab]

  provisioner "local-exec" {
    command = <<-EOT
      IP=$(terraform output -json gitlab_instance_ip | jq -r .value)
      echo "GitLab instance IP: $IP"
      gcloud compute ssh gitlab-server --zone ${var.zone} --command "sudo sed -i 's|http://<YOUR_IP_HERE>|http://$IP|g' /etc/gitlab/gitlab.rb && sudo gitlab-ctl reconfigure"
    EOT
    interpreter = ["bash", "-c"]
  }
}

