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