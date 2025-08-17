variable "ip_name" {
	description = "The name for the PSC IP address."
	type        = string
	default     = "psc-ip"
}

variable "endpoint_name" {
	description = "The name for the PSC consumer endpoint."
	type        = string
	default     = "psc-endpoint"
}

variable "service_attachment_uri" {
	description = "The URI of the published service attachment."
	type        = string
	default     = ""
}

variable "subnetwork" {
	description = "The subnetwork to use for the PSC endpoint."
	type        = string
	default     = ""
}

variable "network" {
	description = "The network to use for the PSC endpoint."
	type        = string
	default     = ""
}

variable "labels" {
	description = "Labels to apply to PSC resources."
	type        = map(string)
	default     = {}
}
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