variable "name" {
	description = "The name of the GCS bucket."
	type        = string
}

variable "location" {
	description = "The location for the bucket (e.g., US, EU, us-central1)."
	type        = string
	default     = "US"
}

variable "storage_class" {
	description = "The storage class of the bucket."
	type        = string
	default     = "STANDARD"
}

variable "force_destroy" {
	description = "Whether to force destroy the bucket (delete all objects)."
	type        = bool
	default     = false
}

variable "labels" {
	description = "A map of labels to assign to the bucket."
	type        = map(string)
	default     = {}
}
