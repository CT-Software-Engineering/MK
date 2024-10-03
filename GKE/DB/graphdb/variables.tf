variable "kubernetes_host" {
  description = "The hostname (in form of URI) of the Kubernetes API."
  type        = string
  default     = "https://35.233.26.165" # Replace with the appropriate IP address or hostname
}

variable "kubernetes_token" {
  description = "The bearer token for authentication to the Kubernetes cluster."
  type        = string
  sensitive   = true
  default     = "80019b7838ce1c49602edab7798515423d17b047" # Replace with the appropriate token
}

variable "kubernetes_ca_cert" {
  description = "Kubernetes CA Certificate"
  type        = string
  sensitive   = true
  
}

variable "neo4j_password" {
  description = "Password for Neo4j database"
  type        = string
  sensitive   = true
  default     = "pa55Word" # Replace with the appropriate password
}

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

variable "gke_cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "militaryknowledge-cluster"
}

variable "gke_cluster_location" {
  description = "The location of the GKE cluster"
  type        = string
  default     = "europe-west1-b"
}
