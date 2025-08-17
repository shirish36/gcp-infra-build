terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

resource "google_compute_network" "vpc" {
  name                    = var.network.name
  auto_create_subnetworks = false
  routing_mode            = var.network.routing_mode
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnets" {
  for_each                 = { for subnet in var.network.subnets : subnet.name => subnet }
  name                     = each.value.name
  ip_cidr_range            = each.value.ip_cidr_range
  region                   = each.value.region
  network                  = google_compute_network.vpc.id
  project                  = var.project_id
  private_ip_google_access = true
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

# Private DNS zone for database resolution
resource "google_dns_managed_zone" "database_zone" {
  name        = "${var.network.name}-database-zone"
  dns_name    = "database.${var.network.name}.internal."
  description = "Private DNS zone for database access within ${var.network.name}"
  project     = var.project_id

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.id
    }
  }

  labels = var.labels
}