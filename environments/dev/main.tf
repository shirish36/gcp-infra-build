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
	vpc_name       = "dev-vpc"
	vpc_description = "Dev VPC"
	subnet_name    = "dev-subnet"
	subnet_cidr    = "10.10.0.0/24"
	region         = var.region
	subnet_description = "Dev subnet"
}

module "gcs_bucket" {
	source        = "../../modules/gcs_bucket"
	name          = "dev-bucket-${var.project_id}"
	location      = var.region
	storage_class = "STANDARD"
	force_destroy = true
	labels        = { env = "dev" }
}

module "cloud_sql" {
	source           = "../../modules/cloud_sql"
	project_id       = var.project_id
	instance_name    = "dev-sql-instance"
	database_version = "SQLSERVER_2019_STANDARD"
	region           = var.region
	tier             = "db-custom-2-3840"
	private_network  = module.network.vpc_id
	disk_size        = 100
	disk_type        = "PD_SSD"
}
