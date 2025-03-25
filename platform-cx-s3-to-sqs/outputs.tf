################################################################################
# Outputs
################################################################################

output "sqs_queue_id" {
  description = "The ID of the SQS queue"
  value       = aws_sqs_queue.this.id
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}

output "sqs_queue_url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.this.url
}

output "sqs_dlq_id" {
  description = "The ID of the SQS dead-letter queue"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].id : null
}

output "sqs_dlq_arn" {
  description = "The ARN of the SQS dead-letter queue"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "sqs_dlq_url" {
  description = "The URL of the SQS dead-letter queue"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].url : null
}

output "bucket_notification_id" {
  description = "The ID of the S3 bucket notification configuration"
  value       = aws_s3_bucket_notification.this.id
}

output "iam_policy_arn" {
  description = "The ARN of the IAM policy for consumers"
  value       = var.create_consumer_policy ? aws_iam_policy.s3_to_sqs[0].arn : null
}

output "iam_policy_id" {
  description = "The ID of the IAM policy for consumers"
  value       = var.create_consumer_policy ? aws_iam_policy.s3_to_sqs[0].id : null
}

output "iam_policy_name" {
  description = "The name of the IAM policy for consumers"
  value       = var.create_consumer_policy ? aws_iam_policy.s3_to_sqs[0].name : null
}

output "customer_role_arn" {
  description = "ARN of the IAM role created for CloudQuery/ClickHouse integration"
  value       = aws_iam_role.customer_role.arn
}

output "customer_role_name" {
  description = "Name of the IAM role created for CloudQuery/ClickHouse integration"
  value       = aws_iam_role.customer_role.name
}

output "external_id" {
  description = "External ID used for role assumption (if provided)"
  value       = var.external_id
}
