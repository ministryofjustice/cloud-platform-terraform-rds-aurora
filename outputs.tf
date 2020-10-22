output "database_username" {
  description = "Database Username"
  value       = aws_rds_cluster.aurora.master_username
}

output "database_password" {
  description = "Database Password"
  value       = aws_rds_cluster.aurora.master_password
}

output "db_identifier" {
  description = "The RDS DB Indentifer"
  value       = aws_rds_cluster.aurora.cluster_identifier
}

output "resource_id" {
  description = "RDS Resource ID - used for performance insights (metrics)"
  value       = aws_rds_cluster.aurora.cluster_resource_id
}

output "rds_instance_endpoint" {
  description = "The connection endpoint in address:port format"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "rds_instance_port" {
  description = "The database port"
  value       = aws_rds_cluster.aurora.port
}

output "database_name" {
  description = "Name of the database"
  value       = aws_rds_cluster.aurora.database_name
}