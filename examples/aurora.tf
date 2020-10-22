

/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "aurora_db" {
  source = "./.."

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


resource "kubernetes_secret" "aurora_db" {
  metadata {
    name      = "example-team-rds-instance-output"
    namespace = "my-namespace"
  }

  data = {
    rds_instance_endpoint = module.aurora_db.rds_instance_endpoint
    database_name         = module.aurora_db.database_name
    database_username     = module.aurora_db.database_username
    database_password     = module.aurora_db.database_password
  }
}