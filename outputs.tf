output "rds_cluster_endpoint" {
  description = "A cluster endpoint (or writer endpoint) for the aurora DB cluster."
  value       = aws_rds_cluster.aurora.endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "A reader endpoint for the aurora DB cluster. Use the reader endpoint for read operations, such as queries"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "rds_instance_endpoint" {
  description = "An instance endpoint connecting the DB instance within an Aurora cluster"
  value       = aws_rds_cluster_instance.aurora_instances[*].endpoint
}

output "rds_cluster_port" {
  description = "The database port"
  value       = aws_rds_cluster.aurora.port
}

output "database_name" {
  description = "Name of the database"
  value       = aws_rds_cluster.aurora.database_name
}

output "database_username" {
  description = "Database Username"
  value       = aws_rds_cluster.aurora.master_username
}

output "database_password" {
  description = "Database Password"
  value       = aws_rds_cluster.aurora.master_password
}

output "db_cluster_identifier" {
  description = "The RDS DB Cluster Indentifer"
  value       = aws_rds_cluster.aurora.cluster_identifier
}

output "resource_id" {
  description = "RDS Resource ID - used for performance insights (metrics)"
  value       = aws_rds_cluster.aurora.cluster_resource_id
}

output "irsa_policy_arn" {
  description = "IAM policy ARN for access to create database snapshots"
  value       = aws_iam_policy.irsa.arn
}
