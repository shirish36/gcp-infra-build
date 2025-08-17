variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "env_name" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "region" {
  description = "The region for the VPC connector."
  type        = string
  default     = "us-central1"
}

variable "connector_subnet_name" {
  description = "The name of the subnet for the VPC connector."
  type        = string
}

variable "min_instances" {
  description = "Minimum number of instances for the VPC connector."
  type        = number
  default     = 2
}

variable "max_instances" {
  description = "Maximum number of instances for the VPC connector."
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Machine type for VPC connector instances."
  type        = string
  default     = "e2-micro"
}
