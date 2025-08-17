terraform {
  backend "gcs" {
    bucket  = "tfstate-bucket-your-project-id" # Change to your bucket name
    prefix  = "terraform/state"
  }
}
