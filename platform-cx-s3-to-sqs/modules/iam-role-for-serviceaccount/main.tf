################################################################################
# IAM Role with Configurable Trust Policy
#
# This creates an IAM role with a configurable trust policy and attaches the
# necessary permissions for S3 and SQS access.
################################################################################

resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name        = var.role_name
  description = var.role_description

  # Use provided assume role policy if specified, otherwise build one based on provided trust options
  assume_role_policy = var.custom_assume_role_policy != null ? var.custom_assume_role_policy : data.aws_iam_policy_document.trust_policy[0].json

  max_session_duration = var.max_session_duration
  path                 = var.path
  permissions_boundary = var.permissions_boundary

  tags = var.tags
}

# Generate a trust policy based on provided trusted entities
data "aws_iam_policy_document" "trust_policy" {
  count = var.create_role && var.custom_assume_role_policy == null ? 1 : 0

  # Allow AWS accounts to assume this role
  dynamic "statement" {
    for_each = length(var.trusted_account_ids) > 0 ? [1] : []

    content {
      sid     = "TrustedAccounts"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = formatlist("arn:aws:iam::%s:root", var.trusted_account_ids)
      }

      dynamic "condition" {
        for_each = var.require_external_id ? [var.external_id] : []

        content {
          test     = "StringEquals"
          variable = "sts:ExternalId"
          values   = [condition.value]
        }
      }
    }
  }

  # Allow specified AWS roles to assume this role
  dynamic "statement" {
    for_each = length(var.trusted_role_arns) > 0 ? [1] : []

    content {
      sid     = "TrustedRoles"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = var.trusted_role_arns
      }
    }
  }

  # Allow Kubernetes service accounts via IRSA
  dynamic "statement" {
    for_each = var.oidc_provider_arn != null ? [1] : []

    content {
      sid     = "EKSServiceAccounts"
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [var.oidc_provider_arn]
      }

      condition {
        test     = "StringEquals"
        variable = "${var.oidc_provider_url}:sub"
        values = [
          for sa in var.service_accounts :
          "system:serviceaccount:${sa.namespace}:${sa.name}"
        ]
      }

      condition {
        test     = "StringEquals"
        variable = "${var.oidc_provider_url}:aud"
        values   = ["sts.amazonaws.com"]
      }
    }
  }

  # Allow EC2 to assume this role (for EC2 instance profiles)
  dynamic "statement" {
    for_each = var.trusted_services != null && contains(var.trusted_services, "ec2.amazonaws.com") ? [1] : []

    content {
      sid     = "EC2AssumeRole"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
    }
  }

  # Allow Lambda to assume this role
  dynamic "statement" {
    for_each = var.trusted_services != null && contains(var.trusted_services, "lambda.amazonaws.com") ? [1] : []

    content {
      sid     = "LambdaAssumeRole"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }
    }
  }
}

# Create the policy for S3 and SQS access
resource "aws_iam_policy" "this" {
  count = var.create_policy ? 1 : 0

  name        = var.policy_name != null ? var.policy_name : "${var.role_name}-policy"
  description = var.policy_description != null ? var.policy_description : "Policy for accessing S3 bucket and SQS queues"
  policy      = data.aws_iam_policy_document.s3_sqs_access.json
  path        = var.path

  tags = var.tags
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "this" {
  count = var.create_role && var.create_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

# Attach any additional policies to the role
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = var.create_role ? toset(var.additional_policy_arns) : toset([])

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

# Create instance profile if requested (for EC2)
resource "aws_iam_instance_profile" "this" {
  count = var.create_role && var.create_instance_profile ? 1 : 0

  name = var.instance_profile_name != null ? var.instance_profile_name : var.role_name
  path = var.path
  role = aws_iam_role.this[0].name

  tags = var.tags
}

# Policy document for S3 and SQS access
data "aws_iam_policy_document" "s3_sqs_access" {
  statement {
    sid    = "AllowSQSAccess"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]
    resources = [var.sqs_queue_arn]
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
    for_each = var.sqs_dlq_arn != null ? [1] : []
    content {
      sid    = "AllowDLQAccess"
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
      ]
      resources = [var.sqs_dlq_arn]
    }
  }
}
