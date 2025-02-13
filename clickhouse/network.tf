# # VPC Flow Logs Configuration
# resource "aws_flow_log" "vpc" {
#   iam_role_arn    = aws_iam_role.vpc_flow_log.arn
#   log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
#   traffic_type    = "ALL"
#   vpc_id          = module.vpc.vpc_id
#
#   tags = var.tags
# }
#
# # CloudWatch Log Group for VPC Flow Logs
# resource "aws_cloudwatch_log_group" "vpc_flow_log" {
#   name_prefix       = "/aws/vpc/flow-log"
#   retention_in_days = var.retention_period
#   kms_key_id        = aws_kms_key.cloudwatch.arn
#
#   tags = var.tags
# }
#
# # IAM Role for VPC Flow Logs
# resource "aws_iam_role" "vpc_flow_log" {
#   name = "vpc-flow-log-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "vpc-flow-logs.amazonaws.com"
#         }
#       }
#     ]
#   })
#
#   tags = var.tags
# }
#
# # IAM Policy for VPC Flow Logs
# resource "aws_iam_role_policy" "vpc_flow_log" {
#   name = "vpc-flow-log-policy"
#   role = aws_iam_role.vpc_flow_log.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:DescribeLogGroups",
#           "logs:DescribeLogStreams"
#         ]
#         Effect   = "Allow"
#         Resource = "${aws_cloudwatch_log_group.vpc_flow_log.arn}:*"
#       }
#     ]
#   })
# }
