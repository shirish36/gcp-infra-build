terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

# Enable required Google Cloud APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",              # Compute Engine API
    "sqladmin.googleapis.com",             # Cloud SQL Admin API
    "dns.googleapis.com",                  # Cloud DNS API - Now manually enabled
    "servicenetworking.googleapis.com",    # Service Networking API
    "storage.googleapis.com",              # Cloud Storage API
    "iam.googleapis.com",                  # Identity and Access Management API
    "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
    "vpcaccess.googleapis.com",            # VPC Access API for Cloud Run
  ])

  project = var.project_id
  service = each.key

  disable_dependent_services = true
  disable_on_destroy         = false
}
