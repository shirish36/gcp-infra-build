terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

resource "google_sql_database_instance" "this" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id
  root_password    = var.root_password

  settings {
    tier = var.tier
    ip_configuration {
      ipv4_enabled = false
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = [var.project_id]
      }
    }
    disk_size = var.disk_size
    disk_type = var.disk_type
    backup_configuration {
      enabled = true
    }
  }
}
