################################################################################
# Variables
################################################################################

#--------------------------------------------------------------
# S3 Bucket Configuration
#--------------------------------------------------------------

variable "s3_bucket_id" {
  description = "The ID of the S3 bucket to configure event notifications for"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
}

variable "existing_bucket_policy" {
  description = "The existing bucket policy to merge with the S3 notification policy (in JSON format)"
  type        = string
  default     = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
}

variable "s3_events" {
  description = "List of S3 events to trigger notifications for"
  type        = list(string)
  default     = ["s3:ObjectCreated:*"]
}

variable "filter_prefix" {
  description = "Optional prefix filter for S3 notifications"
  type        = string
  default     = ""
}

variable "filter_suffix" {
  description = "Optional suffix filter for S3 notifications"
  type        = string
  default     = ""
}

#--------------------------------------------------------------
# SQS Queue Configuration
#--------------------------------------------------------------

variable "queue_name" {
  description = "Name of the SQS queue to create"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue in seconds"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message"
  type        = number
  default     = 345600 # 4 days
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain"
  type        = number
  default     = 262144 # 256 KiB
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive"
  type        = number
  default     = 0
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key for Amazon SQS or a custom CMK"
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "The length of time in seconds for which Amazon SQS can reuse a data key to encrypt or decrypt messages"
  type        = number
  default     = 300 # 5 minutes
}

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = "Specifies whether message deduplication occurs at the message group or queue level"
  type        = string
  default     = "queue"
  validation {
    condition     = contains(["messageGroup", "queue"], var.deduplication_scope)
    error_message = "Deduplication scope must be either 'messageGroup' or 'queue'."
  }
}

variable "fifo_throughput_limit" {
  description = "Specifies whether the FIFO queue throughput quota applies to the entire queue or per message group"
  type        = string
  default     = "perQueue"
  validation {
    condition     = contains(["perQueue", "perMessageGroupId"], var.fifo_throughput_limit)
    error_message = "FIFO throughput limit must be either 'perQueue' or 'perMessageGroupId'."
  }
}

#--------------------------------------------------------------
# Dead Letter Queue Configuration
#--------------------------------------------------------------

variable "enable_dlq" {
  description = "Whether to create a dead-letter queue"
  type        = bool
  default     = false
}

variable "dlq_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the DLQ"
  type        = number
  default     = 1209600 # 14 days
}

variable "dlq_max_receive_count" {
  description = "The number of times a message can be unsuccessfully dequeued before being moved to the DLQ"
  type        = number
  default     = 5
}

#--------------------------------------------------------------
# IAM Policy Configuration
#--------------------------------------------------------------

variable "create_consumer_policy" {
  description = "Whether to create an IAM policy for consumers of this SQS queue"
  type        = bool
  default     = true
}

variable "iam_policy_name" {
  description = "Name of the IAM policy to create for SQS queue consumers"
  type        = string
  default     = "s3-to-sqs-consumer-policy"
}

#--------------------------------------------------------------
# General
#--------------------------------------------------------------

variable "region" {
  type        = string
  description = "The AWS region to deploy to"
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "clickhouse_role_arn" {
  description = "The ARN of the ClickHouse role that will be allowed to assume the customer role"
  type        = string
  default     = ""
}

variable "external_id" {
  description = "The external ID to use for role assumption (recommended for security)"
  type        = string
  default     = ""
}

variable "require_external_id" {
  description = "Whether to require an external ID when assuming the role"
  type        = bool
  default     = true
}

variable "cloudquery_platform_role_arn" {
  description = "The ARN of the CloudQuery Platform role that will be allowed to assume the customer role"
  type        = string
  default     = ""
}

variable "iam_role_name" {
  description = "Name of the IAM role to create for S3 and SQS access"
  type        = string
  default     = "s3-sqs-integration-role"
}
