module "project_apis" {
  source     = "./modules/project_apis"
  project_id = var.project_id
}

module "network" {
  source        = "./modules/network"
  project_id    = var.project_id
  network       = var.network
  region        = var.region
  labels        = var.labels
  custom_domain = var.custom_domain

  depends_on = [module.project_apis]
}

module "gcs_bucket" {
  source        = "./modules/gcs_bucket"
  name          = "tfstate-bucket-${var.project_id}"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = false
  labels        = var.labels

  depends_on = [module.project_apis]
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

  depends_on = [module.project_apis]
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

# VPC Connector for Cloud Run to access private resources
module "vpc_connector" {
  source                 = "./modules/vpc_connector"
  project_id             = var.project_id
  env_name               = var.env_name
  region                 = var.region
  vpc_id                 = module.network.vpc_id
  connector_subnet_name  = "shared-${var.env_name}"
  min_instances          = 2
  max_instances          = 3
  machine_type           = "e2-micro"

  depends_on = [module.network, module.project_apis]
}

# DNS record for database access
resource "google_dns_record_set" "database_dns" {
  name         = "sql-server.database.${var.network.name}.internal."
  managed_zone = module.network.database_zone_name
  type         = "A"
  ttl          = 300
  project      = var.project_id

  rrdatas = [module.psc_endpoint.psc_ip_address]

  depends_on = [module.network, module.psc_endpoint]
}

# Short DNS name for easy access from Cloud Run and other services
resource "google_dns_record_set" "database_short_dns" {
  name         = "db.database.${var.network.name}.internal."
  managed_zone = module.network.database_zone_name
  type         = "A"
  ttl          = 300
  project      = var.project_id

  rrdatas = [module.psc_endpoint.psc_ip_address]

  depends_on = [module.network, module.psc_endpoint]
}

# Even shorter DNS name for maximum convenience
resource "google_dns_record_set" "database_simple_dns" {
  name         = "sqlserver.database.${var.network.name}.internal."
  managed_zone = module.network.database_zone_name
  type         = "A"
  ttl          = 300
  project      = var.project_id

  rrdatas = [module.psc_endpoint.psc_ip_address]

  depends_on = [module.network, module.psc_endpoint]
}

# Custom domain DNS record for easy access (mydb.myorg.com)
resource "google_dns_record_set" "database_custom_dns" {
  name         = "${var.custom_domain.db_hostname}.${var.custom_domain.domain_name}."
  managed_zone = module.network.custom_domain_zone_name
  type         = "A"
  ttl          = 300
  project      = var.project_id

  rrdatas = [module.psc_endpoint.psc_ip_address]

  depends_on = [module.network, module.psc_endpoint]
}
