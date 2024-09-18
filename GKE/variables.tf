variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string

}

variable "zone" {
  description = "The GCP zone"
  type        = string

}

variable "vpc_name" {
  description = "The name of the existing VPC"
  type        = string

}

variable "nat_ip" {
  description = "The static IP address for the NAT gateway"
  type        = string
}

variable "machine_type" {
  description = "The machine type for the GKE nodes"
  type        = string

}
variable "subnetwork" {
  type        = string
  description = "The name of the existing subnetwork"
}
variable "private_subnet" {
  type        = string
  description = "The name of the existing private subnet"
}

variable "public_subnet" {
  type        = string
  description = "The name of the existing public subnet"
}
