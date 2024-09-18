variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default = "militaryknowledge"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default = "europe-west1"

}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default = "europe-west1-b"

}

variable "vpc_name" {
  description = "The name of the existing VPC"
  type        = string
  default = "militaryknowledge-vpc"

}

variable "nat_ip" {
  description = "The static IP address for the NAT gateway"
  type        = string
  default = "null"
}

variable "machine_type" {
  description = "The machine type for the GKE nodes"
  type        = string
  default = "e2-medium"

}
variable "subnetwork" {
  type        = string
  description = "The name of the existing subnetwork"
  default = "militaryknowledge-private-subnet"
}
variable "private_subnet" {
  type        = string
  description = "The name of the existing private subnet"
  default = "militaryknowledge-private-subnet"
}

variable "public_subnet" {
  type        = string
  description = "The name of the existing public subnet"
  default = "militaryknowledge-public-subnet"
}
