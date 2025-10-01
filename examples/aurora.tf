module "rds_aurora" {
  source = "../" # use the latest release
  # source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=version" # use the latest release
  
  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  engine         = "aurora-postgresql"
  engine_version = "14.6"
  engine_mode    = "provisioned"
  instance_type  = "db.t4g.medium"
  replica_count  = 1

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # If you want to enable Cloudwatch logging for this POSTGRESQL Aurora DB cluster, uncomment below:
  # opt_in_xsiam_logging = true
}

resource "kubernetes_secret" "aurora_db" {
  metadata {
    name      = "example-team-rds-cluster-output"
    namespace = "my-namespace"
  }

  data = {
    rds_cluster_endpoint        = module.rds_aurora.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.rds_aurora.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.rds_aurora.db_cluster_identifier
    database_name               = module.rds_aurora.database_name
    database_username           = module.rds_aurora.database_username
    database_password           = module.rds_aurora.database_password
  }
}

module "rds_aurora_mysql" {
  source = "../" # use the latest release
  # source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=version" # use the latest release

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.08.0"
  engine_mode    = "provisioned"
  instance_type  = "db.t4g.medium"
  replica_count  = 1
  allow_major_version_upgrade  = true


  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support 

  # If you want to enable Cloudwatch logging for this MYSQL Aurora DB cluster, uncomment the code below (including the aws_rds_cluster_parameter_group resource at the bottom of this file):
  # opt_in_xsiam_logging = true
  # db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_mysql_audit.name
}

resource "kubernetes_secret" "aurora_mysql_db" {
  metadata {
    name      = "example-team-mysql-rds-cluster-output"
    namespace = "my-namespace"
  }

  data = {
    rds_cluster_endpoint        = module.rds_aurora.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.rds_aurora.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.rds_aurora.db_cluster_identifier
    database_name               = module.rds_aurora.database_name
    database_username           = module.rds_aurora.database_username
    database_password           = module.rds_aurora.database_password
  }
}

# resource "aws_rds_cluster_parameter_group" "aurora_mysql_audit" {
#   name   = "example-aurora-mysql-audit"
#   family = "aurora-mysql8.0"

#   parameter {
#     name  = "server_audit_logging"
#     value = "1"
#     apply_method = "immediate"
#   }

#   parameter {
#     name  = "general_log"
#     value = "1"
#     apply_method = "immediate"
#   }

#   parameter {
#     name  = "server_audit_events"
#     value = "CONNECT,QUERY,TABLE"
#     apply_method = "immediate"
#   }

#   parameter {
#     name  = "slow_query_log"
#     value = "1"
#     apply_method = "immediate"
#   }

#   parameter {
#     name  = "log_output"
#     value = "FILE"
#     apply_method = "immediate"
#   }
# }
