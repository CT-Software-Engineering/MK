terraform {
  backend "gcs" {
    bucket = "militaryknowledge"
    prefix = "GKE/state"

  }
}