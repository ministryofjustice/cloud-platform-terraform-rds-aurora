# cloud-platform-terraform-rds-aurora

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-rds-aurora/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-rds-aurora/releases)

Terraform module which creates RDS Aurora resources on AWS.

## Usage

See [this example](example/aurora.tf)

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_db_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) |
| [aws_iam_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) |
| [aws_iam_user_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) |
| [aws_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) |
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) |
| [aws_rds_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) |
| [aws_rds_cluster_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) |
| [aws_subnet_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) |
| [random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) |
| [random_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) |
| [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allow\_major\_version\_upgrade | Determines whether major engine upgrades will be performed automatically in the maintenance window | `bool` | `false` | no |
| application | n/a | `any` | n/a | yes |
| apply\_immediately | Determines whether or not any DB modifications are applied immediately, or during the maintenance window | `bool` | `false` | no |
| auto\_minor\_version\_upgrade | Determines whether minor engine upgrades will be performed automatically in the maintenance window | `bool` | `true` | no |
| backtrack\_window | The target backtrack window, in seconds. Only available for aurora engine currently. To disable backtracking, set this value to 0. Defaults to 0. Must be between 0 and 259200 (72 hours) | `number` | `0` | no |
| backup\_retention\_period | How long to keep backups for (in days) | `number` | `7` | no |
| business-unit | Area of the MOJ responsible for the service | `string` | `""` | no |
| ca\_cert\_identifier | Specifies the identifier of the CA certificate for the DB instance | `string` | `"rds-ca-2019"` | no |
| cluster\_name | The name of the cluster (eg.: cloud-platform-live-0) | `any` | n/a | yes |
| copy\_tags\_to\_snapshot | Copy all Cluster tags to snapshots. | `bool` | `true` | no |
| db\_cluster\_parameter\_group\_name | The name of a DB Cluster parameter group to use | `string` | `null` | no |
| db\_name | The name of the database to be created on the instance (if empty, it will be the generated random identifier) | `string` | `""` | no |
| db\_parameter\_group\_name | The name of a DB parameter group to use | `string` | `null` | no |
| deletion\_protection | If the DB instance should have deletion protection enabled | `bool` | `false` | no |
| enable\_http\_endpoint | Whether or not to enable the Data API for a serverless Aurora database engine. | `bool` | `false` | no |
| enabled\_cloudwatch\_logs\_exports | List of log types to export to cloudwatch | `list(string)` | `[]` | no |
| engine | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql | `string` | `"aurora"` | no |
| engine\_mode | The database engine mode. Valid values: global, parallelquery, provisioned, serverless, multimaster. | `string` | `"provisioned"` | no |
| engine\_version | Aurora database engine version. | `string` | `""` | no |
| environment-name | n/a | `any` | n/a | yes |
| iam\_database\_authentication\_enabled | Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported. | `bool` | `false` | no |
| infrastructure-support | The team responsible for managing the infrastructure. Should be of the form <team-name> (<team-email>) | `any` | n/a | yes |
| instance\_type | Instance type to use at master instance. If instance\_type\_replica is not set it will use the same type for replica instances | `string` | `"db.t3.medium"` | no |
| instance\_type\_replica | Instance type to use at replica instance | `string` | `null` | no |
| instances\_parameters | Customized instance settings. Supported keys: instance\_name, instance\_type, instance\_promotion\_tier, publicly\_accessible | `list(map(string))` | `[]` | no |
| is-production | n/a | `string` | `"false"` | no |
| namespace | n/a | `string` | `""` | no |
| performance\_insights\_enabled | Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| performance\_insights\_kms\_key\_id | The ARN for the KMS key to encrypt Performance Insights data. | `string` | `""` | no |
| port | The port on which to accept connections | `string` | `""` | no |
| preferred\_backup\_window | When to perform DB backups | `string` | `"02:00-03:00"` | no |
| preferred\_maintenance\_window | When to perform DB maintenance | `string` | `"sun:05:00-sun:06:00"` | no |
| publicly\_accessible | Whether the DB should have a public IP address | `bool` | `false` | no |
| rds\_name | Optional name of the RDS cluster. Changing the name will re-create the RDS | `string` | `""` | no |
| replica\_count | Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead. | `number` | `1` | no |
| replica\_scale\_connections | Average number of connections to trigger autoscaling at. Default value is 70% of db.r4.large's default max\_connections | `number` | `700` | no |
| replica\_scale\_cpu | CPU usage to trigger autoscaling at | `number` | `70` | no |
| replica\_scale\_enabled | Whether to enable autoscaling for RDS Aurora read replicas | `bool` | `false` | no |
| replica\_scale\_max | Maximum number of replicas to allow scaling for | `number` | `0` | no |
| replica\_scale\_min | Minimum number of replicas to allow scaling for | `number` | `2` | no |
| replicate\_source\_db | Specifies that this resource is a Replicate database, and to use this value as the source database. This correlates to the identifier of another Amazon RDS Database to replicate. | `string` | `""` | no |
| replication\_source\_identifier | ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica. | `string` | `""` | no |
| scaling\_configuration | Map of nested attributes with scaling properties. Only valid when engine\_mode is set to `serverless` | `map(string)` | `{}` | no |
| skip\_final\_snapshot | Should a final snapshot be created on cluster destroy | `bool` | `false` | no |
| snapshot\_identifier | DB snapshot to create this database from | `string` | `""` | no |
| storage\_encrypted | Specifies whether the underlying storage layer should be encrypted | `bool` | `true` | no |
| team\_name | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| access\_key\_id | Access key id for RDS IAM user |
| database\_name | Name of the database |
| database\_password | Database Password |
| database\_username | Database Username |
| db\_cluster\_identifier | The RDS DB Cluster Indentifer |
| rds\_cluster\_endpoint | A cluster endpoint (or writer endpoint) for the aurora DB cluster. |
| rds\_cluster\_port | The database port |
| rds\_cluster\_reader\_endpoint | A reader endpoint for the aurora DB cluster. Use the reader endpoint for read operations, such as queries |
| rds\_instance\_endpoint | An instance endpoint connecting the DB instance within an Aurora cluster |
| resource\_id | RDS Resource ID - used for performance insights (metrics) |
| secret\_access\_key | Secret key for RDS IAM user |

<!--- END_TF_DOCS --->

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

## Accessing the database

### Database Hostname/Credentials

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

### Launching psql in the cluster

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

### Accessing your RDS database from your laptop

Instructions on how to do this are available [here](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/rds-external-access.html#accessing-your-rds-database)

### Managing RDS Cluster snapshots - backups and restores

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

## Reading Material

https://github.com/terraform-aws-modules/terraform-aws-rds-aurora

https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine_mode

[decode]: https://github.com/ministryofjustice/cloud-platform-environments/blob/main/bin/decode.rb
[Bitnami]: https://github.com/bitnami/bitnami-docker-postgresql
