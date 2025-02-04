resource "aws_cloudwatch_log_group" "clickhouse" {
  name_prefix       = "clickhouse-"
  retention_in_days = 30

  tags = var.tags

  kms_key_id = aws_kms_key.cloudwatch.arn
}

resource "aws_cloudwatch_log_group" "keeper" {
  name_prefix       = "keeper-"
  retention_in_days = 30

  tags = var.tags

  kms_key_id = aws_kms_key.cloudwatch.arn
}

resource "aws_kms_key" "cloudwatch" {
  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable Root Account Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Administration For Administrators"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Add required data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_alias" "cloudwatch" {
  name          = "alias/clickhouse-cloudwatch"
  target_key_id = aws_kms_key.cloudwatch.key_id
}
