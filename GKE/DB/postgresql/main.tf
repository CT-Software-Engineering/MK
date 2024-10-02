terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  backend "gcs" {
    bucket = "militaryknowledge"
    prefix = "postgresql/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a Cloud SQL instance
resource "google_sql_database_instance" "postgresql_instance" {
  name             = "my-postgresql-instance"
  region           = var.region
  database_version = "POSTGRES_13"

  settings {
    tier = "db-f1-micro"
  }
}

# Create a PostgreSQL database
resource "google_sql_database" "postgresql_db" {
  name     = "my-postgresql-db"
  instance = google_sql_database_instance.postgresql_instance.name
}

# Create a PostgreSQL user
resource "google_sql_user" "postgresql_user" {
  name     = "my-postgresql-user"
  instance = google_sql_database_instance.postgresql_instance.name
  password = var.postgresql_password
}
