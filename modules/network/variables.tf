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
