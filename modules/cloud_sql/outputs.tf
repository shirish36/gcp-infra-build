output "instance_connection_name" {
  description = "The connection name of the Cloud SQL instance."
  value       = google_sql_database_instance.this.connection_name
}

output "instance_self_link" {
  description = "The self link of the Cloud SQL instance."
  value       = google_sql_database_instance.this.self_link
}

output "psc_service_attachment_link" {
  description = "The PSC service attachment link for the Cloud SQL instance."
  value       = google_sql_database_instance.this.psc_service_attachment_link
}

output "private_ip_address" {
  description = "The private IP address of the Cloud SQL instance."
  value       = google_sql_database_instance.this.private_ip_address
}
