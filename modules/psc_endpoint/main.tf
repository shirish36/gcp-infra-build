terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

resource "google_compute_address" "psc_ip_address" {
  name         = var.psc_ip_name
  project      = var.project_id
  region       = var.region
  subnetwork   = var.subnetwork_id
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "consumer_psc_endpoint" {
  name                  = var.psc_endpoint_name
  project               = var.project_id
  region                = var.region
  load_balancing_scheme = ""
  target                = var.psc_service_attachment_link
  network               = var.network_id
  subnetwork            = var.subnetwork_id
  ip_address            = google_compute_address.psc_ip_address.self_link
}
