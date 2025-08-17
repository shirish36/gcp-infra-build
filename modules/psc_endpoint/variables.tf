variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The region for the PSC endpoint."
  type        = string
}

variable "psc_ip_name" {
  description = "The name for the PSC IP address."
  type        = string
}

variable "psc_endpoint_name" {
  description = "The name for the PSC endpoint."
  type        = string
}

variable "network_id" {
  description = "The network ID for the PSC endpoint."
  type        = string
}

variable "subnetwork_id" {
  description = "The subnetwork ID for the PSC endpoint."
  type        = string
}

variable "psc_service_attachment_link" {
  description = "The PSC service attachment link from Cloud SQL."
  type        = string
}
