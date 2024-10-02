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

variable "subnet_name" {
  description = "The name of the existing subnet"
  type        = string
  default     = "militaryknowledge-subnet"
}

variable "public_subnet" {
  description = "public subnet name"
  type        = string
  default     = "militaryknowledge-public-subnet"
}

variable "private_subnet" {
  description = "private subnet name"
  type        = string
  default     = "militaryknowledge-private-subnet"
}
variable "my_nat_gateway" {
  description = "my nat gateway"
  type        = string
  default     = "nat-gateway"
}

variable "nat_router" {
  description = "my nat router"
  type        = string
  default     = "nat-router"
}

variable "my_nat_ip" {
  description = "my nat ip"
  type        = string
  default     = "nat-ip"
}

