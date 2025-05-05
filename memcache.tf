resource "aws_elasticache_cluster" "memcache" {
  cluster_id           = "mjth-memcache-cluster"
  engine               = "memcached"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  engine_version       = "1.6.22"
  subnet_group_name    = aws_elasticache_subnet_group.memcache-subnets.name
  security_group_ids   = [aws_security_group.backend-sg.id]

  tags = {
    Name       = "memcache-cluster"
    Managed_By = "Terraform"
    Project    = var.project
  }

}