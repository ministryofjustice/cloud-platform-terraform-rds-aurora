data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.cluster_name]
  }
  
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    SubnetType = "Private"
  }
}

data "aws_subnet" "private" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  identifier       = var.rds_name != "" ? var.rds_name : "cloud-platform-${random_id.id.hex}"
  db_name          = var.db_name != "" ? var.db_name : "db${random_id.id.hex}"
  port             = var.port == "" ? var.engine == "aurora-postgresql" ? "5432" : "3306" : var.port
  backtrack_window = (var.engine == "aurora-mysql" || var.engine == "aurora") && var.engine_mode != "serverless" ? var.backtrack_window : 0

}

resource "random_string" "username" {
  length  = 8
  special = false
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_kms_key" "kms" {
  description = local.identifier

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${local.identifier}"
  target_key_id = aws_kms_key.kms.key_id
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = local.identifier
  subnet_ids = data.aws_subnet_ids.private.ids

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "aws_security_group" "rds-sg" {
  name        = local.identifier
  description = "Allow all inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  // We cannot use `${aws_db_instance.rds.port}` here because it creates a
  // cyclic dependency. Rather than resorting to `aws_security_group_rule` which
  // is not ideal for managing rules, we will simply allow traffic to all ports.
  // This does not compromise security as the instance only listens on one port.
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [for s in data.aws_subnet.private : s.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [for s in data.aws_subnet.private : s.cidr_block]
  }
}

resource "aws_rds_cluster" "aurora" {

  cluster_identifier                  = local.identifier
  replication_source_identifier       = var.replication_source_identifier
  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = var.engine_version
  database_name                       = local.db_name
  master_username                     = "cp${random_string.username.result}"
  master_password                     = random_password.password.result
  final_snapshot_identifier           = "${local.identifier}-finalsnapshot"
  kms_key_id                          = aws_kms_key.kms.arn
  skip_final_snapshot                 = var.skip_final_snapshot
  deletion_protection                 = var.deletion_protection
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  port                                = local.port
  db_subnet_group_name                = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids              = [aws_security_group.rds-sg.id]
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  db_cluster_parameter_group_name     = var.db_cluster_parameter_group_name
  backtrack_window                    = local.backtrack_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot

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
  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
    cluster_identifier     = local.identifier
  }
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count = var.replica_scale_enabled ? var.replica_scale_min : var.replica_count

  identifier                      = length(var.instances_parameters) > count.index ? lookup(var.instances_parameters[count.index], "instance_name", "${local.identifier}-${count.index + 1}") : "${local.identifier}-${count.index + 1}"
  cluster_identifier              = aws_rds_cluster.aurora.id
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_type
  publicly_accessible             = var.publicly_accessible
  db_subnet_group_name            = aws_db_subnet_group.db_subnet.name
  db_parameter_group_name         = var.db_parameter_group_name
  preferred_maintenance_window    = var.preferred_maintenance_window
  apply_immediately               = var.apply_immediately
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  performance_insights_enabled    = var.performance_insights_enabled
  ca_cert_identifier              = var.ca_cert_identifier
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot

  # Updating engine version forces replacement of instances, and they shouldn't be replaced
  # because cluster will update them if engine version is changed
  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }

  tags = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
    cluster_identifier     = local.identifier
  }
}

resource "aws_iam_user" "user" {
  name  = "rds-cluster-snapshots-user-${random_id.id.hex}"
  path  = "/system/rds-cluster-snapshots-user/"
}

resource "aws_iam_access_key" "user" {
  user  = aws_iam_user.user.name
}

data "aws_iam_policy_document" "policy" {
  statement {
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

resource "aws_iam_user_policy" "policy" {
  name   = "rds-cluster-snapshots-read-write"
  policy = data.aws_iam_policy_document.policy.json
  user   = aws_iam_user.user.name
}

