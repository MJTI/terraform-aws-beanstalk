resource "aws_db_instance" "mysql-db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.39"
  instance_class         = "db.t3.micro"
  availability_zone      = var.subnet_configs["priv-sub-1"].availability_zone
  vpc_security_group_ids = [aws_security_group.backend-sg.id]
  username               = var.mysql-user
  password               = var.mysql-pass
  db_name                = var.database-name
  db_subnet_group_name   = aws_db_subnet_group.private-db-subnets.name
  skip_final_snapshot    = true

  tags = {
    Name       = "mysql-db"
    Managed_By = "Terraform"
    Project    = var.project
  }
}