output "postgresql_instance_name" {
  value = google_sql_database_instance.postgresql_instance.name
}

output "postgresql_db_name" {
  value = google_sql_database.postgresql_db.name
}

output "postgresql_user_name" {
  value = google_sql_user.postgresql_user.name
}

output "postgresql_user_password" {
  value     = var.postgresql_password
  sensitive = true
}
