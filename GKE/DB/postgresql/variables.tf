variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "militaryknowledge"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west1"
}

variable "kubernetes_token" {
  description = "Kubernetes Bearer Token"
  type        = string
  default     = "80019b7838ce1c49602edab7798515423d17b047"
}

variable "postgresql_username" {
  description = "PostgreSQL Username"
  type        = string
  default     = "admin"
}

variable "postgresql_password" {
  description = "PostgreSQL Password"
  type        = string
  default     = "pa55Word" # Replace with the appropriate password
}