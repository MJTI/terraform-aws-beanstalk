resource "aws_mq_broker" "rabbitmq" {
  broker_name                = "mjth-rmq"
  engine_type                = "RabbitMQ"
  engine_version             = "3.13"
  host_instance_type         = "mq.t3.micro"
  auto_minor_version_upgrade = true
  security_groups            = [aws_security_group.backend-sg.id]
  subnet_ids                 = [aws_subnet.private-subnets["priv-sub-1"].id]

  user {
    username = var.rabbitmq-user
    password = var.rabbitmq-pass
  }

  tags = {
    Name       = "mjth-rmq"
    Managed_By = "Terraform"
    Project    = var.project
  }
}
