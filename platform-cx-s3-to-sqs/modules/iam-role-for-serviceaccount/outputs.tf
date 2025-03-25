################################################################################
# Outputs
################################################################################

output "role_name" {
  description = "Name of the IAM role"
  value       = try(aws_iam_role.this[0].name, null)
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = try(aws_iam_role.this[0].arn, null)
}

output "role_id" {
  description = "ID of the IAM role"
  value       = try(aws_iam_role.this[0].id, null)
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = try(aws_iam_policy.this[0].name, null)
}

output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = try(aws_iam_policy.this[0].arn, null)
}

output "policy_id" {
  description = "ID of the IAM policy"
  value       = try(aws_iam_policy.this[0].id, null)
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = try(aws_iam_instance_profile.this[0].arn, null)
}

output "instance_profile_id" {
  description = "ID of the instance profile"
  value       = try(aws_iam_instance_profile.this[0].id, null)
}
