# Network ACLs for private subnets
resource "aws_network_acl" "private" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = var.tags
}

# Inbound rules for private subnets
resource "aws_network_acl_rule" "private_ingress" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = local.vpc_cidr
  from_port      = 0
  to_port        = 0
}

# Inbound return traffic
resource "aws_network_acl_rule" "private_ingress_ephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 101
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 32768
  to_port        = 65535
}

# Outbound rules for private subnets
resource "aws_network_acl_rule" "private_egress" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# VPC Flow Logs Configuration
resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.vpc_flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id

  tags = var.tags
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name_prefix       = "/aws/vpc/flow-log"
  retention_in_days = var.retention_period
  kms_key_id        = aws_kms_key.cloudwatch.arn

  tags = var.tags
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_log" {
  name = "vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "vpc_flow_log" {
  name = "vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.vpc_flow_log.arn}:*"
      }
    ]
  })
}
