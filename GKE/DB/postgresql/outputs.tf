# output "postgresql_instance_name" {
#   value = google_sql_database_instance.postgresql_instance.name
# }

# output "postgresql_db_name" {
#   value = google_sql_database.postgresql_db.name
# }

output "postgresql_user" {
  value = var.postgresql_username
  sensitive = true
}

output "postgresql_password" {
  value     = var.postgresql_password
  sensitive = true
}
