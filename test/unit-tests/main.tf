provider "aws" {
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  region                      = "eu-west-2"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2            = "http://localhost:4566"
    iam            = "http://localhost:4566"
    rds            = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

resource "aws_vpc" "localstack_vpc" {
    cidr_block = "10.0.0.0/16"
    assign_generated_ipv6_cidr_block = false
    tags = {
        Name = "localstack_vpc"
    }
}
resource "aws_subnet" "localstack_vpc_subnet" {
    vpc_id = aws_vpc.localstack_vpc.id
    cidr_block = aws_vpc.localstack_vpc.cidr_block
}

