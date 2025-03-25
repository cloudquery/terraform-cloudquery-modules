################################################################################
# IAM Role and Trust Policy Variables
################################################################################

variable "create_role" {
  description = "Whether to create the IAM role"
  type        = bool
  default     = true
}

variable "create_policy" {
  description = "Whether to create the IAM policy"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = "Role for accessing S3 bucket and SQS queues"
}

variable "policy_name" {
  description = "Name of the IAM policy to create. If not provided, will use role_name-policy"
  type        = string
  default     = null
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = null
}

variable "path" {
  description = "Path for the role and policy"
  type        = string
  default     = "/"
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) for the role"
  type        = number
  default     = 3600
}

variable "permissions_boundary" {
  description = "ARN of the permissions boundary to use for the role"
  type        = string
  default     = null
}

variable "custom_assume_role_policy" {
  description = "A custom assume role policy JSON. If provided, this will be used instead of the generated one"
  type        = string
  default     = null
}

variable "trusted_account_ids" {
  description = "List of AWS account IDs that are allowed to assume this role"
  type        = list(string)
  default     = []
}

variable "trusted_role_arns" {
  description = "List of ARNs of IAM roles that are allowed to assume this role"
  type        = list(string)
  default     = []
}

variable "trusted_services" {
  description = "List of AWS services that are allowed to assume this role (e.g., ec2.amazonaws.com, lambda.amazonaws.com)"
  type        = list(string)
  default     = []
}

variable "require_external_id" {
  description = "Whether to require an external ID when other accounts assume this role"
  type        = bool
  default     = false
}

variable "external_id" {
  description = "External ID to use when other accounts assume this role"
  type        = string
  default     = ""
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA (IAM Roles for Service Accounts)"
  type        = string
  default     = null
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider for IRSA, without the https:// prefix"
  type        = string
  default     = null
}

variable "service_accounts" {
  description = "List of Kubernetes service account objects that are allowed to assume this role via IRSA"
  type = list(object({
    namespace = string
    name      = string
  }))
  default = []
}

variable "create_instance_profile" {
  description = "Whether to create an instance profile for the role"
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Name of the instance profile. If not provided, will use role_name"
  type        = string
  default     = null
}

variable "additional_policy_arns" {
  description = "List of additional policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

################################################################################
# S3 and SQS Resource Variables
################################################################################

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
}

variable "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  type        = string
}

variable "sqs_dlq_arn" {
  description = "The ARN of the SQS dead-letter queue, if any"
  type        = string
  default     = null
}

################################################################################
# General
################################################################################

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
