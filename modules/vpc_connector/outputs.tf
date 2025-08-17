output "connector_id" {
  description = "The ID of the VPC Access connector."
  value       = google_vpc_access_connector.cloud_run_connector.id
}

output "connector_name" {
  description = "The name of the VPC Access connector."
  value       = google_vpc_access_connector.cloud_run_connector.name
}

output "connector_self_link" {
  description = "The self link of the VPC Access connector."
  value       = google_vpc_access_connector.cloud_run_connector.self_link
}

output "connector_state" {
  description = "State of the VPC Access connector."
  value       = google_vpc_access_connector.cloud_run_connector.state
}
