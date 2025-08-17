variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "env_name" {
  description = "Environment name (dev, prod, etc.)"
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

variable "cloud_sql" {
  description = "Cloud SQL configuration."
  type = object({
    instance_name = string
    tier          = string
    root_password = string
  })
  sensitive = true
}
