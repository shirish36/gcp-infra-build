terraform {
	required_providers {
		google = {
			source  = "hashicorp/google"
			version = ">= 5.0.0"
		}
	}
}

resource "google_storage_bucket" "this" {
	name          = var.name
	location      = var.location
	storage_class = var.storage_class
	force_destroy = var.force_destroy

	uniform_bucket_level_access = true

	labels = var.labels
}
