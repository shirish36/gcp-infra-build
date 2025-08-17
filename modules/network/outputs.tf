output "vpc_id" {
	description = "The ID of the VPC."
	value       = google_compute_network.vpc.id
}

output "subnet_id" {
	description = "The ID of the subnet."
	value       = google_compute_subnetwork.subnet.id
}
