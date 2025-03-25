################################################################################
# AWS S3 to SQS Notification Module
#
# This module creates:
# - An IAM policy for S3 to SQS notifications
# - An SQS queue with configurable attributes
# - S3 bucket event notifications to SQS
# - Required S3 bucket policy for allowing S3 to publish to SQS
#
# It requires the following permissions to deploy:
# - iam:CreatePolicy
# - s3:PutBucketNotification
# - s3:PutBucketPolicy
# - sqs:CreateQueue
# - sqs:SetQueueAttributes
################################################################################

#--------------------------------------------------------------
# SQS Queue
#--------------------------------------------------------------

resource "aws_sqs_queue" "this" {
  name                              = var.queue_name
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  policy                            = data.aws_iam_policy_document.sqs_policy.json
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.content_based_deduplication
  deduplication_scope               = var.fifo_queue ? var.deduplication_scope : null
  fifo_throughput_limit             = var.fifo_queue ? var.fifo_throughput_limit : null

  tags = merge(
    var.tags,
    {
      Name = var.queue_name
    }
  )
}

# Create a dead-letter queue if enabled
resource "aws_sqs_queue" "dlq" {
  count = var.enable_dlq ? 1 : 0

  name                              = "${var.queue_name}-dlq${var.fifo_queue ? ".fifo" : ""}"
  message_retention_seconds         = var.dlq_message_retention_seconds
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.content_based_deduplication
  deduplication_scope               = var.fifo_queue ? var.deduplication_scope : null
  fifo_throughput_limit             = var.fifo_queue ? var.fifo_throughput_limit : null

  tags = merge(
    var.tags,
    {
      Name = "${var.queue_name}-dlq"
    }
  )
}

# Set redrive policy for main queue if DLQ is enabled
resource "aws_sqs_queue_redrive_policy" "this" {
  count     = var.enable_dlq ? 1 : 0
  queue_url = aws_sqs_queue.this.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.dlq_max_receive_count
  })
}

# SQS Queue Policy - Allow S3 to send messages
data "aws_iam_policy_document" "sqs_policy" {
  statement {
    sid       = "AllowS3ToSendMessages"
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.queue_name}${var.fifo_queue ? ".fifo" : ""}"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.s3_bucket_arn]
    }
  }

  statement {
    sid       = "AllowOwnerActions"
    effect    = "Allow"
    actions   = ["sqs:*"]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.queue_name}${var.fifo_queue ? ".fifo" : ""}"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

#--------------------------------------------------------------
# S3 Bucket Notification Configuration
#--------------------------------------------------------------

resource "aws_s3_bucket_notification" "this" {
  bucket = var.s3_bucket_id

  queue {
    id            = "${var.queue_name}-notification"
    queue_arn     = aws_sqs_queue.this.arn
    events        = var.s3_events
    filter_prefix = var.filter_prefix
    filter_suffix = var.filter_suffix
  }

  depends_on = [aws_sqs_queue.this, aws_s3_bucket_policy.allow_publish_to_sqs]
}

#--------------------------------------------------------------
# S3 Bucket Policy - Allow S3 to publish to SQS
#--------------------------------------------------------------

resource "aws_s3_bucket_policy" "allow_publish_to_sqs" {
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  source_policy_documents = [var.existing_bucket_policy]

  statement {
    sid    = "AllowS3ToPublishToSQS"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.s3_bucket_arn]
    }
  }
}

#--------------------------------------------------------------
# IAM Policy for S3 to SQS notifications
#--------------------------------------------------------------

resource "aws_iam_policy" "s3_to_sqs" {
  count       = var.create_consumer_policy ? 1 : 0
  name        = var.iam_policy_name
  description = "Policy to process S3 events from ${var.s3_bucket_id} through SQS queue ${var.queue_name}"
  policy      = data.aws_iam_policy_document.sqs_consumer.json
}

data "aws_iam_policy_document" "sqs_consumer" {
  statement {
    sid    = "AllowSQSAccess"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]
    resources = [aws_sqs_queue.this.arn]
  }

  statement {
    sid    = "AllowS3ObjectAccess"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = ["${var.s3_bucket_arn}/*"]
  }

  statement {
    sid    = "AllowS3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [var.s3_bucket_arn]
  }

  dynamic "statement" {
    for_each = var.enable_dlq ? [1] : []
    content {
      sid    = "AllowDLQAccess"
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
      ]
      resources = [aws_sqs_queue.dlq[0].arn]
    }
  }
}

#--------------------------------------------------------------
# IAM Role for CloudQuery Platform and ClickHouse
#--------------------------------------------------------------

resource "aws_iam_role" "customer_role" {
  name        = var.iam_role_name
  description = "Role for CloudQuery Platform and ClickHouse to access S3 and SQS resources"

  # Trust policy that allows both CloudQuery and ClickHouse roles
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      # Add CloudQuery role if specified
      var.cloudquery_platform_role_arn != "" ? [
        {
          Effect = "Allow"
          Principal = {
            AWS = var.cloudquery_platform_role_arn
          }
          Action = "sts:AssumeRole"
          Condition = var.require_external_id && var.external_id != "" ? {
            StringEquals = {
              "sts:ExternalId" = var.external_id
            }
          } : {}
        }
      ] : [],

      # Add ClickHouse role if specified
      var.clickhouse_role_arn != "" ? [
        {
          Effect = "Allow"
          Principal = {
            AWS = var.clickhouse_role_arn
          }
          Action = "sts:AssumeRole"
        }
      ] : []
    )
  })

  tags = var.tags
}

# Create the policy for S3 and SQS access
resource "aws_iam_policy" "s3_sqs_access" {
  name        = "${var.iam_role_name}-policy"
  description = "Policy for accessing S3 bucket and SQS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 bucket-level permissions
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [var.s3_bucket_arn]
      },

      # S3 object-level permissions
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Resource = ["${var.s3_bucket_arn}/*"]
      },

      # SQS permissions
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.this.arn
      }
    ]
  })

  tags = var.tags
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "s3_sqs_access" {
  role       = aws_iam_role.customer_role.name
  policy_arn = aws_iam_policy.s3_sqs_access.arn
}

#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
