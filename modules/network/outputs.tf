output "endpoint_ip" {
	value = google_compute_address.psc_ip.address
}

output "psc_connection_status" {
	value = google_compute_forwarding_rule.consumer_endpoint.psc_connection_status
}

output "psc_connection_id" {
	value = google_compute_forwarding_rule.consumer_endpoint.psc_connection_id
}
output "vpc_id" {
	description = "The ID of the VPC."
	value       = google_compute_network.vpc.id
}

output "subnet_id" {
	description = "The ID of the subnet."
	value       = google_compute_subnetwork.subnet.id
}
