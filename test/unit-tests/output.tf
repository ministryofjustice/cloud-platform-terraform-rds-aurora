output "rds_cluster_endpoint" {
  description = "A cluster endpoint (or writer endpoint) for the aurora DB cluster."
  value       = module.aws_rds_cluster.rds_cluster_endpoint
}


output "db_cluster_identifier" {
  description = "The RDS DB Cluster Indentifer"
  value       = module.aws_rds_cluster.db_cluster_identifier
}
