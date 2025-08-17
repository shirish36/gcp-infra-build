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

variable "vpc_name" {
	description = "The name of the VPC."
	type        = string
}

variable "vpc_description" {
	description = "Description for the VPC."
	type        = string
	default     = "VPC for GCP infrastructure."
}

variable "subnet_name" {
	description = "The name of the subnet."
	type        = string
}

variable "subnet_cidr" {
	description = "The CIDR range for the subnet."
	type        = string
}

variable "region" {
	description = "The region for the subnet."
	type        = string
	default     = "us-central1"
}

variable "subnet_description" {
	description = "Description for the subnet."
	type        = string
	default     = "Subnet for GCP infrastructure."
}
