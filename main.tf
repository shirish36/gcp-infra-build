module "network" {
  source     = "./modules/network"
  project_id = var.project_id
  network    = var.network
  region     = var.region
  labels     = var.labels
}

module "gcs_bucket" {
  source        = "./modules/gcs_bucket"
  name          = "tfstate-bucket-${var.project_id}"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = false
  labels        = var.labels
}

module "cloud_sql" {
  source           = "./modules/cloud_sql"
  project_id       = var.project_id
  instance_name    = var.cloud_sql.instance_name
  database_version = "SQLSERVER_2019_STANDARD"
  region           = var.region
  tier             = var.cloud_sql.tier
  root_password    = var.cloud_sql.root_password
  disk_size        = 100
  disk_type        = "PD_SSD"
}

module "psc_endpoint" {
  source                      = "./modules/psc_endpoint"
  project_id                  = var.project_id
  region                      = var.region
  psc_ip_name                 = "psc-ip-${var.env_name}"
  psc_endpoint_name           = "psc-endpoint-${var.env_name}"
  network_id                  = module.network.vpc_id
  subnetwork_id               = module.network.subnets["db-${var.env_name}"].id
  psc_service_attachment_link = module.cloud_sql.psc_service_attachment_link
}
