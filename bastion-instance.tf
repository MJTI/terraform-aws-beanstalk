data "aws_ssm_parameter" "mjth-key" {
  name = "mjth-key"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion-instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public-subnets["pub-sub-1"].id
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name               = aws_key_pair.deploy-key.key_name

  provisioner "file" {
    content     = templatefile("templates/db-deploy.tftpl", { rds-endpoint = aws_db_instance.mysql-db.address, db-user = var.mysql-user, db-pass = var.mysql-pass, db-name = var.database-name })
    destination = "/tmp/db-deploy.sh"
  }

  connection {
    type        = "ssh"
    user        = var.bastions-username
    private_key = data.aws_ssm_parameter.mjth-key.value
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/db-deploy.sh",
      "/tmp/db-deploy.sh",
    ]
  }

  tags = {
    Name       = "bastion-server"
    Managed_By = "Terraform"
    Project    = var.project
  }
}