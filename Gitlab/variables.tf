variable "project_id" {
  description = "The GCP project ID"
  default     = "militaryknowledge"
}
variable "region" {
  description = "The GCP region"
  default     = "europe-west1"
}
variable "zone" {
  description = "The GCP zone"
  default     = "europe-west1-b"
}
variable "vpc_name" {
  description = "The name of the existing VPC"
  type        = string
  default     = "militaryknowledge-vpc"

}
variable "gitlab_instance_name" {
  type    = string
  default = "gitlab-mkai-repo-vm"
}

variable "machine_type" {
  description = "The machine type for the GKE nodes"
  type        = string
  default     = "e2-custom-medium-5120"
}
variable "subnetwork" {
  type        = string
  description = "The name of the existing subnetwork"
  default     = "militaryknowledge-private-subnet"
}
variable "private_subnet" {
  type        = string
  description = "The name of the existing private subnet"
  default     = "militaryknowledge-private-subnet"
}

variable "public_subnet" {
  type        = string
  description = "The name of the existing public subnet"
  default     = "militaryknowledge-public-subnet"
}

variable "ssh_allowed_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"] # Adjust to restrict SSH access to specific developer IP ranges
}

variable "gitlab_disk_size" {
  type    = string
  default = "50"
}