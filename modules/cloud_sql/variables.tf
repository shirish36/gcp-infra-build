variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "instance_name" {
  description = "The name of the Cloud SQL instance."
  type        = string
}

variable "database_version" {
  description = "The database version (e.g., SQLSERVER_2019_STANDARD)."
  type        = string
}

variable "region" {
  description = "The region for the Cloud SQL instance."
  type        = string
  default     = "us-central1"
}

variable "tier" {
  description = "The machine type tier (e.g., db-custom-2-3840)."
  type        = string
}

variable "disk_size" {
  description = "The size of data disk in GB."
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "The type of data disk (PD_SSD, PD_HDD)."
  type        = string
  default     = "PD_SSD"
}

variable "root_password" {
  description = "The root password for the SQL Server instance."
  type        = string
  sensitive   = true
}
