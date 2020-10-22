# cloud-platform-terraform-_template_

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-template/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-template/releases)

Terraform module which creates RDS Aurora resources on AWS.

## Usage


```hcl
module "example_aurora" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=version"

  team_name              = "example-team"
  business-unit          = "example-bu"
  application            = "exampleapp"
  is-production          = "false"
  namespace              = "my-namespace"
  environment-name       = "development"
  infrastructure-support = "example-team@digital.justice.gov.uk"

# https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine
  engine                 = "aurora-postgresql"

# https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine_version
  # engine_version         = "9.6.9"

# https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine_mode
  # engine_mode            = "serverless"

  rds_name               = "aurora-test"
  replica_count          = 1
  instance_type          = "db.r4.large"
  storage_encrypted      = true
  apply_immediately      = true

}

```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apply\_immediately | Determines whether or not any DB modifications are applied immediately, or during the maintenance window | `bool` | `false` | no |
| auto\_minor\_version\_upgrade | Determines whether minor engine upgrades will be performed automatically in the maintenance window | `bool` | `true` | no |
| backtrack\_window | The target backtrack window, in seconds. Only available for aurora engine currently. To disable backtracking, set this value to 0. Defaults to 0. Must be between 0 and 259200 (72 hours) | `number` | `0` | no |
| backup\_retention\_period | How long to keep backups for (in days) | `number` | `7` | no |
| ca\_cert\_identifier | The identifier of the CA certificate for the DB instance | `string` | `"rds-ca-2019"` | no |
| copy\_tags\_to\_snapshot | Copy all Cluster tags to snapshots. | `bool` | `false` | no |
| database\_name | Name for an automatically created database on cluster creation | `string` | `""` | no |
| db\_cluster\_parameter\_group\_name | The name of a DB Cluster parameter group to use | `string` | `null` | no |
| db\_parameter\_group\_name | The name of a DB parameter group to use | `string` | `null` | no |
| db\_subnet\_group\_name | The existing subnet group name to use | `string` | `""` | no |
| deletion\_protection | If the DB instance should have deletion protection enabled | `bool` | `false` | no |
| engine | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql | `string` | `"aurora"` | no |
| engine\_mode | The database engine mode. Valid values: global, parallelquery, provisioned, serverless, multimaster. | `string` | `"provisioned"` | no |
| engine\_version | Aurora database engine version. | `string` | `"5.6.10a"` | no |
| final\_snapshot\_identifier\_prefix | The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too. | `string` | `"final"` | no |
| instance\_type | Instance type to use at master instance. If instance\_type\_replica is not set it will use the same type for replica instances | `string` | n/a | yes |
| instances\_parameters | Customized instance settings. Supported keys: instance\_name, instance\_type, instance\_promotion\_tier, publicly\_accessible | `list(map(string))` | `[]` | no |
| kms\_key\_id | The ARN for the KMS encryption key if one is set to the cluster. | `string` | `""` | no |
| password | Master DB password | `string` | `""` | no |
| port | The port on which to accept connections | `string` | `""` | no |
| preferred\_backup\_window | When to perform DB backups | `string` | `"02:00-03:00"` | no |
| preferred\_maintenance\_window | When to perform DB maintenance | `string` | `"sun:05:00-sun:06:00"` | no |
| publicly\_accessible | Whether the DB should have a public IP address | `bool` | `false` | no |
| replica\_count | Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead. | `number` | `1` | no |
| replica\_scale\_connections | Average number of connections to trigger autoscaling at. Default value is 70% of db.r4.large's default max\_connections | `number` | `700` | no |
| replica\_scale\_cpu | CPU usage to trigger autoscaling at | `number` | `70` | no |
| replica\_scale\_enabled | Whether to enable autoscaling for RDS Aurora (MySQL) read replicas | `bool` | `false` | no |
| replica\_scale\_in\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale in | `number` | `300` | no |
| replica\_scale\_max | Maximum number of replicas to allow scaling for | `number` | `0` | no |
| replica\_scale\_min | Minimum number of replicas to allow scaling for | `number` | `2` | no |
| replica\_scale\_out\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale out | `number` | `300` | no |
| replication\_source\_identifier | ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica. | `string` | `""` | no |
| scaling\_configuration | Map of nested attributes with scaling properties. Only valid when engine\_mode is set to `serverless` | `map(string)` | `{}` | no |
| skip\_final\_snapshot | Should a final snapshot be created on cluster destroy | `bool` | `false` | no |
| snapshot\_identifier | DB snapshot to create this database from | `string` | `""` | no |
| storage\_encrypted | Specifies whether the underlying storage layer should be encrypted | `bool` | `true` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| username | Master DB username | `string` | `"root"` | no |

## Tags

Some of the inputs are tags. All infrastructure resources need to be tagged according to the [MOJ techincal guidance](https://ministryofjustice.github.io/technical-guidance/standards/documenting-infrastructure-owners/#documenting-owners-of-infrastructure). The tags are stored as variables that you will need to fill out as part of your module.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application |  | string | - | yes |
| business-unit | Area of the MOJ responsible for the service | string | `mojdigital` | yes |
| environment-name |  | string | - | yes |
| infrastructure-support | The team responsible for managing the infrastructure. Should be of the form team-email | string | - | yes |
| is-production |  | string | `false` | yes |
| team_name |  | string | - | yes |

## Outputs

_Describe the outputs_
| Name | Description |
|------|-------------|
| rds_instance_endpoint | The connection endpoint in address:port format |
| rds_instance_port | The database port |
| database_name | Name of the database |
| database_username | Database Username |
| database_password | Database Password |
| db_identifier | DB Identifier of the RDS instance |

## Reading Material

https://github.com/terraform-aws-modules/terraform-aws-rds-aurora

https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine_mode