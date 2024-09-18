terraform {
  backend "gcs" {
    bucket = "militaryknowledge"
    prefix = "Infra/state"

  }
}