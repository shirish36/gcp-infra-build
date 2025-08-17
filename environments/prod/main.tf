terraform {
	required_version = ">= 1.3.0"
	required_providers {
		google = {
			source  = "hashicorp/google"
			version = ">= 5.0.0"
		}
	}
}

provider "google" {
	project = var.project_id
	region  = var.region
}

module "network" {
	source         = "../../modules/network"
	project_id     = var.project_id
	vpc_name       = "prod-vpc"
	vpc_description = "Prod VPC"
	subnet_name    = "prod-subnet"
	subnet_cidr    = "10.20.0.0/24"
	region         = var.region
	subnet_description = "Prod subnet"
}

module "gcs_bucket" {
	source        = "../../modules/gcs_bucket"
	name          = "prod-bucket-${var.project_id}"
	location      = var.region
	storage_class = "STANDARD"
	force_destroy = false
	labels        = { env = "prod" }
}

module "cloud_sql" {
	source           = "../../modules/cloud_sql"
	project_id       = var.project_id
	instance_name    = "prod-sql-instance"
	database_version = "SQLSERVER_2019_STANDARD"
	region           = var.region
	tier             = "db-custom-4-7680"
	private_network  = module.network.vpc_id
	disk_size        = 200
	disk_type        = "PD_SSD"
}
