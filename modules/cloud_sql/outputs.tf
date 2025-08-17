output "instance_connection_name" {
	description = "The connection name of the Cloud SQL instance."
	value       = google_sql_database_instance.this.connection_name
}

output "instance_self_link" {
	description = "The self link of the Cloud SQL instance."
	value       = google_sql_database_instance.this.self_link
}
