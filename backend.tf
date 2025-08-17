terraform {
  backend "gcs" {
    bucket  = "tfstate-bucket-your-project-id" # Change to your bucket name
    prefix  = "terraform/state/${var.env_name}"
  }
}

variable "env_name" {
  description = "The environment name (e.g., dev, prod) for state separation."
  type        = string
}
