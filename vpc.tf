resource "aws_vpc" "mjth-vpc" {
  cidr_block = var.vpc-cidr

  tags = {
    Name       = var.vpc-name
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_eip" "nat-eip" {
  domain = "vpc"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mjth-vpc.id

  tags = {
    Name       = "igw"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_nat_gateway" "nat-igw" {

  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnets["pub-sub-1"].id

  tags = {
    Name       = "nat-igw"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_subnet" "public-subnets" {
  for_each = { for k, v in var.subnet_configs : k => v if v.is_public }

  vpc_id                  = aws_vpc.mjth-vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name       = each.key
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_subnet" "private-subnets" {
  for_each = { for k, v in var.subnet_configs : k => v if !v.is_public }

  vpc_id                  = aws_vpc.mjth-vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name       = each.key
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_db_subnet_group" "private-db-subnets" {
  name = "private database subnets"

  subnet_ids = [for s in aws_subnet.private-subnets : s.id]

  tags = {
    Name       = "private-db-subnets"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_elasticache_subnet_group" "memcache-subnets" {
  name       = "memcache-private-subnets"
  subnet_ids = [for s in aws_subnet.private-subnets : s.id]

  tags = {
    Name       = "private-memcache-subnets"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_route_table" "pub-route-table" {
  vpc_id = aws_vpc.mjth-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = var.vpc-cidr
    gateway_id = "local"
  }

  tags = {
    Name       = "public-route-table"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_route_table" "priv-route-table" {
  vpc_id = aws_vpc.mjth-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-igw.id
  }

  route {
    cidr_block = var.vpc-cidr
    gateway_id = "local"
  }

  tags = {
    Name       = "private-route-table"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_route_table_association" "for-public-subnets" {
  for_each = aws_subnet.public-subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.pub-route-table.id
}

resource "aws_route_table_association" "for-private-subnets" {
  for_each = aws_subnet.private-subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.priv-route-table.id
}