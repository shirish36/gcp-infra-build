resource "google_compute_address" "psc_ip" {
	name         = var.ip_name
	project      = var.project_id
	region       = var.region
	subnetwork   = var.subnetwork
	address_type = "INTERNAL"
	labels       = var.labels
}

resource "google_compute_forwarding_rule" "consumer_endpoint" {
	name                  = var.endpoint_name
	project               = var.project_id
	region                = var.region
	load_balancing_scheme = "INTERNAL_MANAGED"
	target                = var.service_attachment_uri
	network               = var.network
	subnetwork            = var.subnetwork
	ip_address            = google_compute_address.psc_ip.address
	labels                = var.labels
}
resource "google_compute_global_address" "private_ip_range" {
	name          = "private-ip-range"
	purpose       = "VPC_PEERING"
	address_type  = "INTERNAL"
	prefix_length = 16
	network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
	network                 = google_compute_network.vpc.id
	service                 = "servicenetworking.googleapis.com"
	reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}
terraform {
	required_providers {
		google = {
			source  = "hashicorp/google"
			version = ">= 5.0.0"
		}
	}
}

resource "google_compute_network" "vpc" {
	name                    = var.vpc_name
	auto_create_subnetworks = false
	routing_mode            = "REGIONAL"
	description             = var.vpc_description
	project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
	name          = var.subnet_name
	ip_cidr_range = var.subnet_cidr
	region        = var.region
	network       = google_compute_network.vpc.id
	project       = var.project_id
	private_ip_google_access = true
	description   = var.subnet_description
}
