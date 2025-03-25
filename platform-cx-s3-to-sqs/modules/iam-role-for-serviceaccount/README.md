<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.s3_sqs_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM role | `string` | n/a | yes |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | The ARN of the S3 bucket | `string` | n/a | yes |
| <a name="input_sqs_queue_arn"></a> [sqs\_queue\_arn](#input\_sqs\_queue\_arn) | The ARN of the SQS queue | `string` | n/a | yes |
| <a name="input_additional_policy_arns"></a> [additional\_policy\_arns](#input\_additional\_policy\_arns) | List of additional policy ARNs to attach to the role | `list(string)` | `[]` | no |
| <a name="input_create_instance_profile"></a> [create\_instance\_profile](#input\_create\_instance\_profile) | Whether to create an instance profile for the role | `bool` | `false` | no |
| <a name="input_create_policy"></a> [create\_policy](#input\_create\_policy) | Whether to create the IAM policy | `bool` | `true` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Whether to create the IAM role | `bool` | `true` | no |
| <a name="input_custom_assume_role_policy"></a> [custom\_assume\_role\_policy](#input\_custom\_assume\_role\_policy) | A custom assume role policy JSON. If provided, this will be used instead of the generated one | `string` | `null` | no |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | External ID to use when other accounts assume this role | `string` | `""` | no |
| <a name="input_instance_profile_name"></a> [instance\_profile\_name](#input\_instance\_profile\_name) | Name of the instance profile. If not provided, will use role\_name | `string` | `null` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration (in seconds) for the role | `number` | `3600` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | ARN of the OIDC provider for IRSA (IAM Roles for Service Accounts) | `string` | `null` | no |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL of the OIDC provider for IRSA, without the https:// prefix | `string` | `null` | no |
| <a name="input_path"></a> [path](#input\_path) | Path for the role and policy | `string` | `"/"` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | ARN of the permissions boundary to use for the role | `string` | `null` | no |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | Description of the IAM policy | `string` | `null` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name of the IAM policy to create. If not provided, will use role\_name-policy | `string` | `null` | no |
| <a name="input_require_external_id"></a> [require\_external\_id](#input\_require\_external\_id) | Whether to require an external ID when other accounts assume this role | `bool` | `false` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | Description of the IAM role | `string` | `"Role for accessing S3 bucket and SQS queues"` | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | List of Kubernetes service account objects that are allowed to assume this role via IRSA | <pre>list(object({<br/>    namespace = string<br/>    name      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_sqs_dlq_arn"></a> [sqs\_dlq\_arn](#input\_sqs\_dlq\_arn) | The ARN of the SQS dead-letter queue, if any | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources | `map(string)` | `{}` | no |
| <a name="input_trusted_account_ids"></a> [trusted\_account\_ids](#input\_trusted\_account\_ids) | List of AWS account IDs that are allowed to assume this role | `list(string)` | `[]` | no |
| <a name="input_trusted_role_arns"></a> [trusted\_role\_arns](#input\_trusted\_role\_arns) | List of ARNs of IAM roles that are allowed to assume this role | `list(string)` | `[]` | no |
| <a name="input_trusted_services"></a> [trusted\_services](#input\_trusted\_services) | List of AWS services that are allowed to assume this role (e.g., ec2.amazonaws.com, lambda.amazonaws.com) | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_profile_arn"></a> [instance\_profile\_arn](#output\_instance\_profile\_arn) | ARN of the instance profile |
| <a name="output_instance_profile_id"></a> [instance\_profile\_id](#output\_instance\_profile\_id) | ID of the instance profile |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | Name of the instance profile |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | ARN of the IAM policy |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | ID of the IAM policy |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | Name of the IAM policy |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | ID of the IAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role |
<!-- END_TF_DOCS -->
