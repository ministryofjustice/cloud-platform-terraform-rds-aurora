package main

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// An example of how to test the Terraform module in examples/terraform-aws-rds-example using Terratest.
func TestTerraformAwsRdsAuroraPostgresqlExample(t *testing.T) {
	t.Parallel()

	awsRegion := "eu-west-2"
	expectedDBIdentifier := fmt.Sprintf("terratest-rds-aurora-postgres-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-tests",
		Vars: map[string]interface{}{
			"rds_name":     expectedDBIdentifier,
			"cluster_name": "default",
		},
		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	clusterIdentifier := terraform.Output(t, terraformOptions, "cluster_identifier")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedDBIdentifier, clusterIdentifier)

	// Run `terraform output` to get the value of an output variable
	endpoint := terraform.Output(t, terraformOptions, "endpoint")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, endpoint, fmt.Sprintf(":cluster:%s", expectedDBIdentifier))

}
