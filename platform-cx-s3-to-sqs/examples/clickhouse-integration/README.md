<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_to_sqs_integration"></a> [s3\_to\_sqs\_integration](#module\_s3\_to\_sqs\_integration) | github.com/cloudquery/terraform-aws-s3-to-sqs | n/a |

## Resources

| Name | Type |
|------|------|
| [random_id.external_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configuration_instructions"></a> [configuration\_instructions](#output\_configuration\_instructions) | Instructions for providing the role information to ClickHouse Cloud |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role to provide to ClickHouse Cloud |
| <a name="output_role_external_id"></a> [role\_external\_id](#output\_role\_external\_id) | The external ID to provide to ClickHouse Cloud (keep this secure) |
| <a name="output_sqs_queue_arn"></a> [sqs\_queue\_arn](#output\_sqs\_queue\_arn) | The ARN of the SQS queue |
| <a name="output_sqs_queue_url"></a> [sqs\_queue\_url](#output\_sqs\_queue\_url) | The URL of the SQS queue receiving S3 event notifications |
<!-- END_TF_DOCS -->
