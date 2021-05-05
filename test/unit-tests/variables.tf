variable "rds_name" {
  description = "Optional name of the RDS cluster. Changing the name will re-create the RDS"
}

variable "cluster_name" {
  description = "The name of the cluster (eg.: live-1)"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "172.20.0.0/16"
}

variable "internal_subnets" {
  type        = list(string)
  description = "list of subnet CIDR blocks that are not publicly acceessibly"
  default     = ["172.20.32.0/19", "172.20.64.0/19", "172.20.96.0/19"]
}

variable "external_subnets" {
  type        = list(string)
  description = "list of subnet CIDR blocks that are publicly acceessibly"
  default     = ["172.20.0.0/22", "172.20.4.0/22", "172.20.8.0/22"]
}
variable "availability_zones" {
  type        = list(string)
  description = "a list of EC2 availability zones"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "cluster_names" {
  description = "A list of every Kubernetes cluster present in the VPC"
  type        = list(string)
  default     = []
}