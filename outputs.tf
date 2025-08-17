output "vpc_id" {
  description = "The ID of the VPC network."
  value       = module.network.vpc_id
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

output "gcs_bucket_name" {
  description = "The name of the GCS bucket."
  value       = module.gcs_bucket.bucket_name
}

output "gcs_bucket_url" {
  description = "The URL of the GCS bucket."
  value       = module.gcs_bucket.bucket_url
}
