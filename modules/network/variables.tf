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