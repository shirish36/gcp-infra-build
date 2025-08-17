terraform {
  backend "gcs" {
    bucket = "tfstate-bucket-283962084457" # Change to your bucket name
    prefix = "terraform/state/dev"
  }
}

