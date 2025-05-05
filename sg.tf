resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "Allowing ssh for a bastion server"
  vpc_id      = aws_vpc.mjth-vpc.id
  tags = {
    Name       = "bastion-sg"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_security_group" "backend-sg" {
  name        = "backend-sg"
  description = "Allowing tomcat to connecto to (mysql - rabbitMQ - memcache)"
  vpc_id      = aws_vpc.mjth-vpc.id
  tags = {
    Name       = "backend-sg"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_security_group" "beanstalk-tomcat" {
  name        = "beanstalk-tomcat"
  description = "Allowing port 80 from ALB"
  vpc_id      = aws_vpc.mjth-vpc.id
  tags = {
    Name       = "beanstalk-tomcat"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_security_group" "ALB-beanstalk-sg" {
  name        = "ALB-beanstalk-tomcat"
  description = "Allowing port 80 from anywhere"
  vpc_id      = aws_vpc.mjth-vpc.id
  tags = {
    Name       = "ALB-beanstalk-tomcat"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  for_each = {
    bastion   = aws_security_group.bastion-sg
    backend   = aws_security_group.backend-sg
    beanstalk = aws_security_group.beanstalk-tomcat
    ALB       = aws_security_group.ALB-beanstalk-sg
  }

  security_group_id = each.value.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  for_each = {
    bastion   = aws_security_group.bastion-sg
    backend   = aws_security_group.backend-sg
    beanstalk = aws_security_group.beanstalk-tomcat
    ALB       = aws_security_group.ALB-beanstalk-sg
  }

  security_group_id = each.value.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh-bastion" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = var.myip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow-bastion-connect-db" {
  security_group_id            = aws_security_group.backend-sg.id
  referenced_security_group_id = aws_security_group.bastion-sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow-tomcat-connect-db" {
  security_group_id            = aws_security_group.backend-sg.id
  referenced_security_group_id = aws_security_group.beanstalk-tomcat.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow-tomcat-connect-rmq" {
  security_group_id            = aws_security_group.backend-sg.id
  referenced_security_group_id = aws_security_group.beanstalk-tomcat.id
  from_port                    = 5671
  ip_protocol                  = "tcp"
  to_port                      = 5671
}

resource "aws_vpc_security_group_ingress_rule" "allow-tomcat-connect-mc" {
  security_group_id            = aws_security_group.backend-sg.id
  referenced_security_group_id = aws_security_group.beanstalk-tomcat.id
  from_port                    = 11211
  ip_protocol                  = "tcp"
  to_port                      = 11211
}

resource "aws_vpc_security_group_ingress_rule" "allow-ALB-connect-tomcat" {
  security_group_id            = aws_security_group.beanstalk-tomcat.id
  referenced_security_group_id = aws_security_group.ALB-beanstalk-sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow-anywhere-IPv4-ALB" {
  security_group_id = aws_security_group.ALB-beanstalk-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow-anywhere-IPv6-ALB" {
  security_group_id = aws_security_group.ALB-beanstalk-sg.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}