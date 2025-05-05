terraform {
  backend "s3" {
    bucket = "terraform-mj-state"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}
