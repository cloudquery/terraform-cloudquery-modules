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

  tags = var.tags
}

resource "aws_kms_alias" "cloudwatch" {
  name          = "alias/clickhouse-cloudwatch"
  target_key_id = aws_kms_key.cloudwatch.key_id
}
