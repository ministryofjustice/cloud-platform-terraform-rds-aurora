output "rds_cluster_endpoint" {
  description = "A cluster endpoint (or writer endpoint) for the aurora DB cluster."
  value       = aws_rds_cluster.aurora.endpoint
}


output "db_cluster_identifier" {
  description = "The RDS DB Cluster Indentifer"
  value       = aws_rds_cluster.aurora.cluster_identifier
}
