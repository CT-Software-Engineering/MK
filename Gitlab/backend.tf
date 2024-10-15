terraform {
  backend "gcs" {
    bucket = "militaryknowledge"
    prefix = "gitlab/state"

  }
}