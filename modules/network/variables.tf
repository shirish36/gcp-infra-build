variable "project_id" {
  description = "The GCP project ID."
  type        = string
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

variable "region" {
  description = "The region for the subnet."
  type        = string
  default     = "us-central1"
}

variable "labels" {
  description = "Labels to apply to network resources."
  type        = map(string)
  default     = {}
}

variable "custom_domain" {
  description = "Custom domain configuration for database DNS."
  type = object({
    domain_name = string
    db_hostname = string
  })
  default = {
    domain_name = "myorg.com"
    db_hostname = "mydb"
  }
}