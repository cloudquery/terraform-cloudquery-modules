# Example for dual integration (CloudQuery Platform and ClickHouse)
# This creates an IAM role that both services can assume to access your S3 and SQS resources

provider "aws" {
  region = "us-west-2" # Change to your preferred region
}

# Generate a secure random external ID
resource "random_id" "external_id" {
  byte_length = 8
}

locals {
  # Replace these with the actual ARNs provided to you
  cloudquery_role_arn = "arn:aws:iam::586794438123:role/cq-platform-eks-latest-cloudquery-sync"
  clickhouse_role_arn = "arn:aws:iam::191110999071:role/CH-S3-steel-mv-95-ue1-42-Role"

  # Your existing S3 bucket information
  existing_bucket_name = "your-existing-bucket"
  existing_bucket_arn  = "arn:aws:s3:::your-existing-bucket"

  # External ID with prefix for better identification
  external_id = "integration-${random_id.external_id.hex}"
}

module "dual_integration" {
  source = "../../platform-cx-s3-to-sqs"

  # Existing S3 bucket details
  s3_bucket_id  = local.existing_bucket_name
  s3_bucket_arn = local.existing_bucket_arn

  # SQS queue configuration
  queue_name    = "${local.existing_bucket_name}-notifications"
  s3_events     = ["s3:ObjectCreated:*"]
  filter_prefix = "data/" # Optional: Filter events by prefix

  # Role configuration for both CloudQuery and ClickHouse
  iam_role_name       = "cloudquery-clickhouse-integration-role"
  cloudquery_role_arn = local.cloudquery_role_arn
  clickhouse_role_arn = local.clickhouse_role_arn
  require_external_id = true
  external_id         = local.external_id

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# Output the configuration information
output "role_arn" {
  description = "The ARN of the IAM role that CloudQuery and ClickHouse can assume"
  value       = module.dual_integration.customer_role_arn
}

output "external_id" {
  description = "The external ID for role assumption (share with both services)"
  value       = local.external_id
  sensitive   = true
}

output "sqs_queue_url" {
  description = "The URL of the SQS queue receiving S3 event notifications"
  value       = module.dual_integration.sqs_queue_url
}

output "configuration_instructions" {
  description = "Instructions for integration"
  value       = <<EOT
    ## Integration Instructions

    Provide the following information to both CloudQuery Platform and ClickHouse:

    1. Role ARN: ${module.dual_integration.customer_role_arn}
    2. External ID: ${local.external_id}
    3. S3 Bucket Name: ${local.existing_bucket_name}
    4. SQS Queue URL: ${module.dual_integration.sqs_queue_url}

    This role has been configured to allow both services to:
    - Access data in your S3 bucket
    - Receive and process messages from the SQS queue

    Note: Keep the external ID secure - it's required when either service assumes this role.
  EOT
}
