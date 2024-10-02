terraform {
  backend "gcs" {
    bucket = "militaryknowledge"
    prefix = "graphdb/state"

  }
}