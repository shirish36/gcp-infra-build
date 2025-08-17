resource "google_vpc_access_connector" "cloud_run_connector" {
  name          = "vpc-connector-${var.env_name}"
  project       = var.project_id
  region        = var.region
  network       = var.vpc_id
  
  # Use the shared services subnet for VPC connector
  subnet {
    name       = var.connector_subnet_name
    project_id = var.project_id
  }

  # VPC connector instance settings
  min_instances = var.min_instances
  max_instances = var.max_instances
  
  # Machine type for connector instances
  machine_type = var.machine_type
}
