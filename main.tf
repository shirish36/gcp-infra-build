module "network" {
  source         = "./modules/network"
  project_id     = var.project_id
  vpc_name       = "main-vpc"
  vpc_description = "Main VPC"
  subnet_name    = "main-subnet"
  subnet_cidr    = "10.30.0.0/24"
  region         = var.region
  subnet_description = "Main subnet"
}

module "gcs_bucket" {
  source        = "./modules/gcs_bucket"
  name          = "tfstate-bucket-${var.project_id}"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = false
  labels        = { env = "tfstate" }
}

module "cloud_sql" {
  source           = "./modules/cloud_sql"
  project_id       = var.project_id
  instance_name    = "main-sql-instance"
  database_version = "SQLSERVER_2019_STANDARD"
  region           = var.region
  tier             = "db-custom-2-3840"
  private_network  = module.network.vpc_id
  disk_size        = 100
  disk_type        = "PD_SSD"
}
