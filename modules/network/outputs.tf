output "vpc_id" {
  description = "The ID of the VPC."
  value       = google_compute_network.vpc.id
}

output "vpc_self_link" {
  description = "The self link of the VPC."
  value       = google_compute_network.vpc.self_link
}

output "subnets" {
  description = "Map of subnet names to their details."
  value = {
    for subnet in google_compute_subnetwork.subnets :
    subnet.name => {
      id        = subnet.id
      self_link = subnet.self_link
      region    = subnet.region
    }
  }
}

# DNS Zone outputs commented out due to permission issues
# Uncomment when DNS Administrator role is granted to service account
/*
output "database_zone_name" {
  description = "The name of the private DNS zone for database access."
  value       = google_dns_managed_zone.database_zone.name
}

output "database_zone_dns_name" {
  description = "The DNS name of the private zone for database access."
  value       = google_dns_managed_zone.database_zone.dns_name
}
*/