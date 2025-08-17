output "vpc_id" {
  description = "The ID of the VPC network."
  value       = module.network.vpc_id
}

output "enabled_apis" {
  description = "List of enabled GCP APIs."
  value       = module.project_apis.enabled_apis
}

output "vpc_self_link" {
  description = "The self link of the VPC network."
  value       = module.network.vpc_self_link
}

output "subnets" {
  description = "Map of subnet names to their details."
  value       = module.network.subnets
}

output "cloud_sql_instance_connection_name" {
  description = "The connection name of the Cloud SQL instance."
  value       = module.cloud_sql.instance_connection_name
}

output "cloud_sql_psc_service_attachment" {
  description = "The PSC service attachment link for the Cloud SQL instance."
  value       = module.cloud_sql.psc_service_attachment_link
}

output "psc_endpoint_ip" {
  description = "The private IP address of the PSC endpoint for Cloud SQL."
  value       = module.psc_endpoint.psc_ip_address
}

output "psc_dns_name" {
  description = "The DNS name for the PSC endpoint."
  value       = module.psc_endpoint.psc_dns_name
}

output "database_dns_fqdn" {
  description = "The FQDN for database access via DNS."
  value       = "sql-server.database.${var.network.name}.internal"
}

output "database_dns_short" {
  description = "Short DNS name for database access (recommended for Cloud Run)."
  value       = "db.database.${var.network.name}.internal"
}

output "database_dns_simple" {
  description = "Simple DNS name for database access (shortest option)."
  value       = "sqlserver.database.${var.network.name}.internal"
}

output "database_zone_name" {
  description = "The private DNS zone name for database access."
  value       = module.network.database_zone_name
}

output "gcs_bucket_name" {
  description = "The name of the GCS bucket."
  value       = module.gcs_bucket.bucket_name
}

output "gcs_bucket_url" {
  description = "The URL of the GCS bucket."
  value       = module.gcs_bucket.bucket_url
}
