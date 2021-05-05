
module "aurora_postgres_db" {
  source = "../.."
  team_name              = "example-team"
  business-unit          = "example-bu"
  application            = "exampleapp"
  is-production          = "false"
  namespace              = "my-namespace"
  environment-name       = "development"
  infrastructure-support = "example-team@digital.justice.gov.uk"

# https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine
  engine                 = "aurora-postgresql"
  rds_name = var.rds_name
  cluster_name = var.cluster_name
}

