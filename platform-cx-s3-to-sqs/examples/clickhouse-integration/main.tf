# Example for ClickHouse integration with existing S3 bucket
# This creates an IAM role that allows ClickHouse to access your S3 data

provider "aws" {
  region = "us-east-1" # Change to the region where your S3 bucket is located
}

locals {
  # ClickHouse IAM role ARN - THIS SHOULD BE THE ACTUAL ROLE ARN PROVIDED BY CLICKHOUSE
  clickhouse_role_arn = "arn:aws:iam::191110999071:role/CH-S3-steel-mv-95-ue1-42-Role"

  # Your existing S3 bucket information
  existing_bucket_name = "your-existing-bucket"
  existing_bucket_arn  = "arn:aws:s3:::your-existing-bucket"
}

module "clickhouse_integration" {
  source = "github.com/cloudquery/terraform-cloudquery-modules/platform-cx-s3-to-sqs"

  # Existing S3 bucket details
  s3_bucket_id  = local.existing_bucket_name
  s3_bucket_arn = local.existing_bucket_arn

  # The SQS queue is optional for ClickHouse, but we'll create it anyway
  # to maintain compatibility with the module
  queue_name = "${local.existing_bucket_name}-notifications"

  # Create IAM role with appropriate trust policy for ClickHouse
  iam_role_name       = "clickhouse-s3-access-role"
  clickhouse_role_arn = local.clickhouse_role_arn
}

# Output the information needed to provide to ClickHouse
output "role_arn" {
  description = "The ARN of the IAM role to provide to ClickHouse"
  value       = module.clickhouse_integration.customer_role_arn
}

output "bucket_name" {
  description = "The name of the S3 bucket to provide to ClickHouse"
  value       = local.existing_bucket_name
}

output "configuration_instructions" {
  description = "Instructions for ClickHouse integration"
  value       = <<-EOT
    ## ClickHouse Integration Instructions

    Provide the following information to ClickHouse:

    1. Role ARN: ${module.clickhouse_integration.customer_role_arn}
    2. S3 Bucket Name: ${local.existing_bucket_name}

    This role has been configured with the exact permissions required by ClickHouse
    to access your S3 bucket data.
  EOT
}
