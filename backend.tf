terraform {
  backend "gcs" {
    bucket  = "tfstate-bucket-283962084457" # Change to your bucket name
    prefix  = "terraform/state/dev"
  }
}

variable "env_name" {
  description = "The environment name (e.g., dev, prod) for state separation."
  type        = string
}
