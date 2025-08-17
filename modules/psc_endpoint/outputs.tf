output "psc_ip_address" {
  description = "The PSC IP address."
  value       = google_compute_address.psc_ip_address.address
}

output "psc_endpoint_id" {
  description = "The PSC endpoint ID."
  value       = google_compute_forwarding_rule.consumer_psc_endpoint.id
}

output "psc_dns_name" {
  description = "The DNS name for the PSC endpoint."
  value       = google_compute_forwarding_rule.consumer_psc_endpoint.service_name
}
