locals {
  # Generic configuration
  identifier       = "cloud-platform-${random_id.id.hex}"
  vpc_name         = (var.vpc_name == "live") ? "live-1" : var.vpc_name
  db_name          = (var.db_name != "") ? var.db_name : "db${random_id.id.hex}"
  port             = (var.port == "") ? (var.engine == "aurora-postgresql") ? "5432" : "3306" : var.port
  backtrack_window = (var.engine == "aurora-mysql" || var.engine == "aurora") && var.engine_mode != "serverless" ? var.backtrack_window : 0

  # engine-to-export log configuration mappings
  db_log_export_mappings = {
    aurora-postgresql = ["postgresql"], 
    aurora-mysql      = ["audit", "error", "general", "slowquery"]
  }

  # Retrieve logs from user-selected engine
  log_exports = var.opt_in_xsiam_logging ? lookup(local.db_log_export_mappings, var.engine, []) : []

  # Tags
  default_tags = {
    # Mandatory
    business-unit = var.business_unit
    application   = var.application
    is-production = var.is_production
    owner         = var.team_name
    namespace     = var.namespace # for billing and identification purposes

    # Optional
    environment-name       = var.environment_name
    infrastructure-support = var.infrastructure_support
  }
}

##################
# Get AWS region #
##################
data "aws_region" "current" {}

###########################
# Get account information #
###########################
data "aws_caller_identity" "current" {}

#######################
# Get VPC information #
#######################
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    SubnetType = "Private"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_subnets" "eks_private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    SubnetType = "EKS-Private"
  }
}

data "aws_subnet" "eks_private" {
  for_each = toset(data.aws_subnets.eks_private.ids)
  id       = each.value
}


########################
# Generate identifiers #
########################
resource "random_id" "id" {
  byte_length = 8
}

resource "random_string" "username" {
  length  = 8
  special = false
}

resource "random_password" "password" {
  length  = 16
  special = false
}

#########################
# Create encryption key #
#########################
resource "aws_kms_key" "kms" {
  description = local.identifier

  tags = local.default_tags
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${local.identifier}"
  target_key_id = aws_kms_key.kms.key_id
}

##########################
# Create Security Groups #
##########################
resource "aws_security_group" "rds-sg" {
  name        = local.identifier
  description = "Allow all inbound traffic"
  vpc_id      = data.aws_vpc.this.id

  # We cannot use `${aws_db_instance.rds.port}` here because it creates a
  # cyclic dependency. Rather than resorting to `aws_security_group_rule` which
  # is not ideal for managing rules, we will simply allow traffic to all ports.
  # This does not compromise security as the instance only listens on one port.
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = concat(
      [for s in data.aws_subnet.private : s.cidr_block],
      [for s in data.aws_subnet.eks_private : s.cidr_block]
    )
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = concat(
      [for s in data.aws_subnet.private : s.cidr_block],
      [for s in data.aws_subnet.eks_private : s.cidr_block]
    )
  }

  tags = local.default_tags
}

#########################
# Create Aurora cluster #
#########################
resource "aws_db_subnet_group" "db_subnet" {
  name       = local.identifier
  subnet_ids = data.aws_subnets.private.ids

  tags = local.default_tags
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier              = local.identifier
  replication_source_identifier   = var.replication_source_identifier
  engine                          = var.engine
  engine_mode                     = var.engine_mode
  engine_version                  = var.engine_version
  database_name                   = var.skip_setting_when_migrated ? null : local.db_name
  master_username                 = var.skip_setting_when_migrated ? null : "cp${random_string.username.result}"
  master_password                 = random_password.password.result
  final_snapshot_identifier       = "${local.identifier}-finalsnapshot"
  kms_key_id                      = aws_kms_key.kms.arn
  skip_final_snapshot             = var.skip_final_snapshot
  deletion_protection             = var.deletion_protection
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  port                            = local.port
  db_subnet_group_name            = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids          = [aws_security_group.rds-sg.id]
  snapshot_identifier             = var.snapshot_identifier
  storage_encrypted               = true
  apply_immediately               = true
  allow_major_version_upgrade     = var.allow_major_version_upgrade
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  backtrack_window                = local.backtrack_window
  copy_tags_to_snapshot           = true
  enabled_cloudwatch_logs_exports = local.log_exports

  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }

  dynamic "serverlessv2_scaling_configuration" {
    for_each = length(keys(var.serverlessv2_scaling_configuration)) == 0 ? [] : [var.serverlessv2_scaling_configuration]

    content {
      max_capacity = lookup(serverlessv2_scaling_configuration.value, "max_capacity", null)
      min_capacity = lookup(serverlessv2_scaling_configuration.value, "min_capacity", null)
    }
  }

  lifecycle {
    precondition {
      condition     = !(var.engine == "aurora-mysql" && var.opt_in_xsiam_logging && (var.db_cluster_parameter_group_name == null || var.db_cluster_parameter_group_name == ""))
      error_message = "You must provide a db_cluster_parameter_group_name with the parameters set in the /examples folder when enabling XSIAM Cortex logs for MYSQL Aurora."
    }
 }

  tags = merge(local.default_tags, {
    cluster_identifier = local.identifier
  })

  depends_on = [aws_cloudwatch_log_subscription_filter.rds_aurora_logs_to_firehose]
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count = var.replica_scale_enabled ? var.replica_scale_min : var.replica_count

  identifier                   = length(var.instances_parameters) > count.index ? lookup(var.instances_parameters[count.index], "instance_name", "${local.identifier}-${count.index + 1}") : "${local.identifier}-${count.index + 1}"
  cluster_identifier           = aws_rds_cluster.aurora.id
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_type
  publicly_accessible          = var.publicly_accessible
  db_subnet_group_name         = aws_db_subnet_group.db_subnet.name
  db_parameter_group_name      = var.db_parameter_group_name
  preferred_maintenance_window = var.preferred_maintenance_window
  apply_immediately            = true
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  performance_insights_enabled = var.performance_insights_enabled
  ca_cert_identifier           = var.ca_cert_identifier
  copy_tags_to_snapshot        = true

  # Updating engine version forces replacement of instances, and they shouldn't be replaced
  # because cluster will update them if engine version is changed
  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }

  tags = merge(local.default_tags, {
    cluster_identifier = local.identifier
  })
}

# Short-lived credentials (IRSA)
data "aws_iam_policy_document" "irsa" {
  version = "2012-10-17"

  statement {
    sid    = "AllowRDSAccessFor${random_id.id.hex}"
    effect = "Allow"
    actions = [
      "rds:DescribeDBClusterSnapshots",
      "rds:DescribeDBClusters",
      "rds:CopyDBClusterSnapshot",
      "rds:DeleteDBClusterSnapshot",
      "rds:DescribeDBClusterSnapshotAttributes",
      "rds:CreateDBClusterSnapshot",
      "rds:ModifyDBClusterSnapshotAttribute",
      "rds:RestoreDBClusterFromSnapshot",
    ]

    resources = [
      aws_rds_cluster.aurora.arn,
      "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster-snapshot:*",
    ]
  }
}

resource "aws_iam_policy" "irsa" {
  name   = "cloud-platform-rds-aurora-${random_id.id.hex}"
  path   = "/cloud-platform/rds-aurora/"
  policy = data.aws_iam_policy_document.irsa.json
  tags   = local.default_tags
}

data "aws_iam_roles" "cloudwatch_to_firehose" {
  name_regex = "cloud-platform-cloudwatch-to-firehose20250912120805499500000001"
}

data "aws_kinesis_firehose_delivery_stream" "rds_aurora_log_stream" {
  name = "cloudwatch-export-180af1363ef3510a"
}

resource "aws_cloudwatch_log_group" "rds_aurora_cloudwatch_logs" {
  for_each = var.opt_in_xsiam_logging ? toset(local.log_exports) : []

  name              = "/aws/rds/cluster/${local.identifier}/${each.key}"
  retention_in_days = 14
  tags              = local.default_tags
}

resource "aws_cloudwatch_log_subscription_filter" "rds_aurora_logs_to_firehose" {
  for_each = var.opt_in_xsiam_logging ? aws_cloudwatch_log_group.rds_aurora_cloudwatch_logs : {}

  name            = "${local.identifier}-${each.key}-firehose"
  log_group_name  = "/aws/rds/cluster/${local.identifier}/${each.key}"
  filter_pattern  = ""
  destination_arn = data.aws_kinesis_firehose_delivery_stream.rds_aurora_log_stream.arn
  role_arn        = length(data.aws_iam_roles.cloudwatch_to_firehose.arns) > 0 ? tolist(data.aws_iam_roles.cloudwatch_to_firehose.arns)[0] : null

  depends_on = [aws_cloudwatch_log_group.rds_aurora_cloudwatch_logs]
}

