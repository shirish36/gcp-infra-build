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
  private_network  = module.network.vpc_self_link
  disk_size        = 100
  disk_type        = "PD_SSD"
}
