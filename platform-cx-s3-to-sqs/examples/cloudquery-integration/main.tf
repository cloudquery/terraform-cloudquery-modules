# Example for CloudQuery Platform integration with an existing S3 bucket
# This creates:
# 1. A new SQS queue in the customer account
# 2. S3 event notifications to the SQS queue
# 3. An IAM role that CloudQuery Platform can assume to access both resources

# Generate a secure random external ID
resource "random_id" "external_id" {
  byte_length = 8
}

# Replace these with your actual S3 bucket details
locals {
  # CloudQuery Platform Role ARN - THIS SHOULD BE THE ACTUAL ROLE ARN PROVIDED TO YOU
  cloudquery_role_arn = "arn:aws:iam::586794438123:role/cq-platform-eks-latest-cloudquery-sync"

  # Customer's existing S3 bucket information
  existing_bucket_name = "your-existing-bucket"
  existing_bucket_arn  = "arn:aws:s3:::your-existing-bucket"
}

module "cloudquery_integration" {
  source = "../../"

  # Region where the resources will be created
  region = "us-west-2"

  # Existing S3 bucket details
  s3_bucket_id  = local.existing_bucket_name
  s3_bucket_arn = local.existing_bucket_arn

  # SQS queue configuration
  queue_name = "${local.existing_bucket_name}-notifications"
  s3_events  = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  enable_dlq = true

  # Optional: Filter events by prefix/suffix
  filter_prefix = "uploads/" # Only monitor this prefix, remove if not needed

  # Create IAM role with appropriate trust policy for CloudQuery Platform
  iam_role_name                = "cloudquery-platform-s3-sqs-access"
  cloudquery_platform_role_arn = local.cloudquery_role_arn
  require_external_id          = true
  external_id                  = "cloudquery-${random_id.external_id.hex}" # Secure random external ID
}

# Output the information needed to provide to CloudQuery Platform
output "role_arn" {
  description = "The ARN of the IAM role to provide to CloudQuery Platform"
  value       = module.cloudquery_integration.customer_role_arn
}

output "role_external_id" {
  description = "The external ID to provide to CloudQuery Platform (keep this secure)"
  value       = "cloudquery-${random_id.external_id.hex}"
  sensitive   = true
}

output "sqs_queue_url" {
  description = "The URL of the SQS queue receiving S3 event notifications"
  value       = module.cloudquery_integration.sqs_queue_url
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.cloudquery_integration.sqs_queue_arn
}

output "configuration_instructions" {
  description = "Instructions for providing the role information to CloudQuery Platform"
  value       = <<-EOT
    ## Configuration Instructions

    Provide the following information to CloudQuery Platform:

    1. Role ARN: ${module.cloudquery_integration.customer_role_arn}
    2. External ID: [Available in the Terraform state or CLI output]
    3. SQS Queue URL: ${module.cloudquery_integration.sqs_queue_url}

    To update your bucket when data changes:
    - Files added to s3://${local.existing_bucket_name}/uploads/ will trigger notifications
    - CloudQuery Platform will poll the SQS queue and process new files

    Note: Keep the external ID secure - it's required when CloudQuery Platform assumes this role.
  EOT
}
