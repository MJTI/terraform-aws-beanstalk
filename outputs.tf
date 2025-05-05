output "RDS-Hostname" {
  value = aws_db_instance.mysql-db.endpoint
}

output "RMQ-Hostname" {
  value = aws_mq_broker.rabbitmq.instances.0.endpoints
}

output "Memcache-Hostname" {
  value = aws_elasticache_cluster.memcache.cluster_address
}