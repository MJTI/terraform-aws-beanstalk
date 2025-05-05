resource "aws_key_pair" "deploy-key" {
  key_name   = "deploy-key"
  public_key = var.mjth-pub

  tags = {
    Name       = "deploy-key"
    Managed_By = "Terraform"
    Project    = var.project
  }
}