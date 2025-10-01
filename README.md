# cloud-platform-terraform-rds-aurora

[![Releases](https://img.shields.io/github/v/release/ministryofjustice/cloud-platform-terraform-rds-aurora.svg)](https://github.com/ministryofjustice/cloud-platform-terraform-rds-aurora/releases)

This Terraform module will create an [Amazon Aurora](https://aws.amazon.com/rds/aurora/) database for use on the Cloud Platform.

## Usage

```hcl
module "rds_aurora" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=version" # use the latest release

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  engine         = "aurora-postgresql"
  engine_version = "14.7"
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
}
```

### Accessing the database

#### Database Hostname/Credentials

The hostname and credentials for accessing your database will be in a
kubernetes secret inside your namespace. You can retrieve them as follows (the
`decode.rb` script is available [here][decode]):

```
$ kubectl -n [your namespace] get secret [secret name] -o yaml | ./decode.rb
---
apiVersion: v1
data:
  database_name: ...
  database_password: ...
  database_username: ...
  access_key_id: ...
  secret_access_key: ...
  rds_instance_address: cloud-platform-xxxxx.yyyyy.eu-west-2.rds.amazonaws.com
  rds_instance_endpoint: cloud-platform-xxxxx.yyyyy.eu-west-2.rds.amazonaws.com:5432
  rds_instance_port: '5432'
kind: Secret
metadata:
  creationTimestamp: '2019-05-08T16:14:23Z'
  name: secret-name
  namespace: your-namespace
  resourceVersion: '11111111'
  selfLink: "/api/v1/namespaces/your-namespace/secrets/secret-name"
  uid: 11111111-1111-1111-1111-111111111111
type: Opaque
```

If you are exporting a database URL from your RDS kubernetes secret, it might have a value like this:

```
postgres://cpDvquXO5B:R1eDN0xEUnaH6Aqr@cloud-platform-df3589e0e7acba37.cdwm328dlye6.eu-west-2.rds.amazonaws.com:5432/dbdf3589e0e7acba37
```

The database hostname is part between `@` and `:` In the example above, the database hostname is:

```
cloud-platform-df3589e0e7acba37.cdwm328dlye6.eu-west-2.rds.amazonaws.com
```

> NB: You should *always* get the database credentials from this kubernetes secret. Do not be tempted to copy the into another location (such as a ConfigMap). This is because the value of the secret can be updated when this module is updated. As long as you always get your database credentials from the kubernetes secret created by terraform, this is fine. But if you copy the value elsewhere, it will not be automatically updated in the new location, and your application will no longer be able to connect to your database.

#### Launching psql in the cluster

A Docker image containing the `psql` utility is available from [Bitnami] (you
cannot use the official postgres image, because it runs as root) and can be
launched like this:

```
$ kubectl -n [your namespace] run --generator=run-pod/v1 shell --rm -i --tty --image bitnami/postgresql -- bash
If you don't see a command prompt, try pressing enter.
postgres@shell:/$
```

You can then connect to your database like this

```
postgres@shell:/$ psql -h [rds_instance_address] -U [database_username] [database_name]
Password for username: [...enter database_password here...]
psql (10.7, server 10.6)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
[database_name]=>
```

#### Accessing your RDS database from your laptop

Instructions on how to do this are available [here](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/rds-external-access.html#accessing-your-rds-database)

#### Managing RDS Cluster snapshots - backups and restores

An IAM user account is created which allows management of RDS Cluster snapshots - allowing snapshot create, delete, copy, restore.

Example usage via AWS CLI:

List RDS Cluster snapshots
```
aws rds describe-db-cluster-snapshots --db-cluster-identifier [db_cluster_identifier]
```

Create snapshot
```
aws rds create-db-cluster-snapshot
--db-cluster-identifier [db_cluster_identifier] --db-cluster-snapshot-identifier [your-snapshot-name]
```

See the [examples/](examples/) folder for more information.

## Enabling Logging to XSIAM Cortex

If you are required to stream logs to XSIAM Cortex for security auditing, you can do so by setting `opt_in_xsiam_logging` variable to true. In the case of mysql Aurora engines, you will need to create a parameter group and pass in the 'db_cluster_parameter_group_name' var. Please ensure the parameters defined in the /examples folder are set, with 'apply_method' for each as "immediate"

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.rds_aurora_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_subscription_filter.rds_aurora_logs_to_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_db_subnet_group.db_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_policy.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_rds_cluster.aurora](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.aurora_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_security_group.rds-sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_roles.cloudwatch_to_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_kinesis_firehose_delivery_stream.rds_aurora_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kinesis_firehose_delivery_stream) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.eks_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.eks_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Determines whether major engine upgrades will be performed automatically in the maintenance window | `bool` | `false` | no |
| <a name="input_application"></a> [application](#input\_application) | Application name | `string` | n/a | yes |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Determines whether minor engine upgrades will be performed automatically in the maintenance window | `bool` | `true` | no |
| <a name="input_backtrack_window"></a> [backtrack\_window](#input\_backtrack\_window) | The target backtrack window, in seconds. Only available for aurora engine currently. To disable backtracking, set this value to 0. Defaults to 0. Must be between 0 and 259200 (72 hours) | `number` | `0` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | How long to keep backups for (in days) | `number` | `7` | no |
| <a name="input_business_unit"></a> [business\_unit](#input\_business\_unit) | Area of the MOJ responsible for the service | `string` | n/a | yes |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | Specifies the identifier of the CA certificate for the DB instance | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#input\_db\_cluster\_parameter\_group\_name) | The name of a DB Cluster parameter group to use. If you are enabling XSIAM Cortex logging for MYSQL Aurora, you must include the parameters set in the /examples folder | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name of the database to be created on the instance (if empty, it will be the generated random identifier) | `string` | `""` | no |
| <a name="input_db_parameter_group_name"></a> [db\_parameter\_group\_name](#input\_db\_parameter\_group\_name) | The name of a DB parameter group to use | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the DB instance should have deletion protection enabled | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql | `string` | `"aurora"` | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | The database engine mode. Valid values: global, parallelquery, provisioned, serverless, multimaster. | `string` | `"provisioned"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Aurora database engine version. | `string` | `""` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Environment name | `string` | n/a | yes |
| <a name="input_infrastructure_support"></a> [infrastructure\_support](#input\_infrastructure\_support) | The team responsible for managing the infrastructure. Should be of the form <team-name> (<team-email>) | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use at master instance. If instance\_type\_replica is not set it will use the same type for replica instances | `string` | `"db.t3.medium"` | no |
| <a name="input_instances_parameters"></a> [instances\_parameters](#input\_instances\_parameters) | Customized instance settings. Supported keys: instance\_name, instance\_type, instance\_promotion\_tier, publicly\_accessible | `list(map(string))` | `[]` | no |
| <a name="input_is_production"></a> [is\_production](#input\_is\_production) | Whether this is used for production or not | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace name | `string` | n/a | yes |
| <a name="input_opt_in_xsiam_logging"></a> [opt\_in\_xsiam\_logging](#input\_opt\_in\_xsiam\_logging) | If set to true, it will create Cloudwatch log groups for the RDS Aurora instance and send them to Cortex XSIAM. For MYSQL engines, you must also pass in a 'db\_cluster\_parameter\_group\_name' var, with logging parameters set (see 'Enabling Logging to XSIAM Cortex' section in README) | `bool` | `false` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which to accept connections | `string` | `""` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | When to perform DB backups | `string` | `"02:00-03:00"` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | When to perform DB maintenance | `string` | `"sun:05:00-sun:06:00"` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Whether the DB should have a public IP address | `bool` | `false` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead. | `number` | `1` | no |
| <a name="input_replica_scale_enabled"></a> [replica\_scale\_enabled](#input\_replica\_scale\_enabled) | Whether to enable autoscaling for RDS Aurora read replicas | `bool` | `false` | no |
| <a name="input_replica_scale_min"></a> [replica\_scale\_min](#input\_replica\_scale\_min) | Minimum number of replicas to allow scaling for | `number` | `2` | no |
| <a name="input_replication_source_identifier"></a> [replication\_source\_identifier](#input\_replication\_source\_identifier) | ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica. | `string` | `""` | no |
| <a name="input_scaling_configuration"></a> [scaling\_configuration](#input\_scaling\_configuration) | Map of nested attributes with scaling properties. Only valid when engine\_mode is set to `serverless` | `map(string)` | `{}` | no |
| <a name="input_serverlessv2_scaling_configuration"></a> [serverlessv2\_scaling\_configuration](#input\_serverlessv2\_scaling\_configuration) | Map of nested attributes with scaling properties (`max_capacity`, `min_capacity`) for Aurora Serverless v2. Only valid when engine mode is set to `provisioned`. The `instance_type` variable must also be set to `db.serverless` | `map(string)` | `{}` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Should a final snapshot be created on cluster destroy | `bool` | `false` | no |
| <a name="input_skip_setting_when_migrated"></a> [skip\_setting\_when\_migrated](#input\_skip\_setting\_when\_migrated) | Setting a database name on a replica creates a loop because Aurora tries to change terraform's random string to the source name + some other random string | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | DB snapshot to create this database from | `string` | `""` | no |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | Team name | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the vpc (eg.: live-1) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Name of the database |
| <a name="output_database_password"></a> [database\_password](#output\_database\_password) | Database Password |
| <a name="output_database_username"></a> [database\_username](#output\_database\_username) | Database Username |
| <a name="output_db_cluster_identifier"></a> [db\_cluster\_identifier](#output\_db\_cluster\_identifier) | The RDS DB Cluster Indentifer |
| <a name="output_irsa_policy_arn"></a> [irsa\_policy\_arn](#output\_irsa\_policy\_arn) | IAM policy ARN for access to create database snapshots |
| <a name="output_rds_cluster_endpoint"></a> [rds\_cluster\_endpoint](#output\_rds\_cluster\_endpoint) | A cluster endpoint (or writer endpoint) for the aurora DB cluster. |
| <a name="output_rds_cluster_port"></a> [rds\_cluster\_port](#output\_rds\_cluster\_port) | The database port |
| <a name="output_rds_cluster_reader_endpoint"></a> [rds\_cluster\_reader\_endpoint](#output\_rds\_cluster\_reader\_endpoint) | A reader endpoint for the aurora DB cluster. Use the reader endpoint for read operations, such as queries |
| <a name="output_rds_instance_endpoint"></a> [rds\_instance\_endpoint](#output\_rds\_instance\_endpoint) | An instance endpoint connecting the DB instance within an Aurora cluster |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | RDS Resource ID - used for performance insights (metrics) |
<!-- END_TF_DOCS -->

## Tags

Some of the inputs for this module are tags. All infrastructure resources must be tagged to meet the MOJ Technical Guidance on [Documenting owners of infrastructure](https://technical-guidance.service.justice.gov.uk/documentation/standards/documenting-infrastructure-owners.html).

You should use your namespace variables to populate these. See the [Usage](#usage) section for more information.

## Reading Material

- [Cloud Platform user guide](https://user-guide.cloud-platform.service.justice.gov.uk/#cloud-platform-user-guide)
- [Amazon Aurora user guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html)

[decode]: https://github.com/ministryofjustice/cloud-platform-environments/blob/main/bin/decode.rb
[Bitnami]: https://github.com/bitnami/bitnami-docker-postgresql
