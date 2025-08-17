variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The region to deploy resources."
  type        = string
  default     = "us-central1"
}

variable "labels" {
  description = "Labels to apply to resources."
  type        = map(string)
  default     = {}
}

variable "network" {
  description = "Network configuration including name, routing mode and subnets."
  type = object({
    name         = string
    routing_mode = string
    subnets = list(object({
      name          = string
      ip_cidr_range = string
      region        = string
    }))
  })
}

variable "psc_db_subnet_name" {
  description = "The name of the subnet to use for PSC database connection."
  type        = string
}

variable "vpc_connector" {
  description = "VPC connector configuration."
  type = object({
    name          = string
    ip_cidr_range = string
  })
}

variable "cloud_sql" {
  description = "Cloud SQL configuration."
  type = object({
    instance_name = string
    tier          = string
  })
}
