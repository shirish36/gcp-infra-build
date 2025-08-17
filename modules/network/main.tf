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
