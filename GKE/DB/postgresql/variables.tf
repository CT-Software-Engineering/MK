variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "militaryknowledge"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-west1"
}
variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "europe-west1-b"

}
variable "postgresql_password" {
  description = "The password for the PostgreSQL user"
  type        = string
  sensitive   = true
  default     = "pa55Word"
}
variable "postgresql_user" {
  description = "The password for the PostgreSQL user"
  type        = string
  sensitive   = true
  default     = "admin"
}