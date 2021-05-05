variable "rds_name" {
  description = "Optional name of the RDS cluster. Changing the name will re-create the RDS"
}

variable "cluster_name" {
  description = "The name of the cluster (eg.: live-1)"
}