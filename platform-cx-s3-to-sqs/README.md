# AWS S3 to SQS Integration Module

This Terraform module helps you integrate your AWS S3 bucket with CloudQuery Platform and/or ClickHouse by creating the necessary resources and permissions.

## What This Module Creates

- **SQS Queue**: For S3 event notifications when objects are created/updated
- **S3 Bucket Event Notifications**: Configured to send events to the SQS queue
- **IAM Role**: With the necessary permissions for CloudQuery Platform and/or ClickHouse

## Prerequisites

- AWS account with permissions to create SQS queues, IAM roles, and modify S3 bucket policies
- Terraform v0.14+ installed
- An existing S3 bucket

## Usage

### Basic Setup with CloudQuery Platform Integration

```hcl
module "s3_to_sqs_integration" {
  source = "github.com/cloudquery/terraform-cloudquery-modules/platform-cx-s3-to-sqs"

  # Existing S3 bucket details
  s3_bucket_id  = "my-existing-bucket"
  s3_bucket_arn = "arn:aws:s3:::my-existing-bucket"

  # SQS queue configuration
  queue_name    = "my-existing-bucket-notifications"

  # CloudQuery Platform integration
  cloudquery_platform_role_arn = "arn:aws:iam::767397982801:role/cloudquery-platform-production"
  iam_role_name               = "cloudquery-platform-access"
  external_id                 = "cloudquery-${random_id.external_id.hex}"
  require_external_id         = true
}

resource "random_id" "external_id" {
  byte_length = 8
}
```

### ClickHouse Integration

```hcl
module "clickhouse_integration" {
  source = "github.com/cloudquery/terraform-cloudquery-modules/platform-cx-s3-to-sqs"

  # Existing S3 bucket details
  s3_bucket_id  = "my-existing-bucket"
  s3_bucket_arn = "arn:aws:s3:::my-existing-bucket"

  # SQS queue configuration (optional for ClickHouse)
  queue_name    = "my-existing-bucket-notifications"

  # ClickHouse integration
  clickhouse_role_arn = "arn:aws:iam::012345678901:role/ClickHouse-Integration-Role"
  iam_role_name       = "clickhouse-s3-access-role"
}
```

### Dual Integration (CloudQuery Platform and ClickHouse)

```hcl
module "dual_integration" {
  source = "github.com/cloudquery/terraform-cloudquery-modules/platform-cx-s3-to-sqs"

  # Existing S3 bucket details
  s3_bucket_id  = "my-existing-bucket"
  s3_bucket_arn = "arn:aws:s3:::my-existing-bucket"

  # SQS queue configuration
  queue_name    = "my-existing-bucket-notifications"
  s3_events     = ["s3:ObjectCreated:*"]
  filter_prefix = "data/"  # Optional: Filter events by prefix

  # Role configuration for both services
  iam_role_name               = "dual-integration-role"
  cloudquery_platform_role_arn = "arn:aws:iam::767397982801:role/cloudquery-platform-production"
  clickhouse_role_arn         = "arn:aws:iam::012345678901:role/ClickHouse-Integration-Role"
  external_id                 = "integration-${random_id.external_id.hex}"
}

resource "random_id" "external_id" {
  byte_length = 8
}
```

## Examples

The module includes several example configurations:

1. [`examples/cloudquery-integration`](examples/cloudquery-integration/main.tf): Setting up CloudQuery Platform integration
2. [`examples/clickhouse-integration`](examples/clickhouse-integration/main.tf): Setting up ClickHouse integration
3. [`examples/dual-integration`](examples/dual-integration/main.tf): Setting up both integrations with a single role

## How It Works

1. The module creates an SQS queue in your AWS account
2. It configures your S3 bucket to send event notifications to the SQS queue
3. It creates an IAM role that CloudQuery Platform and/or ClickHouse can assume
4. You provide the Role ARN, External ID (if used), and other details to the service(s)
5. The services can then securely access your data using these credentials

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.0.0 |

## Providers

| Name                                             | Version  |
| ------------------------------------------------ | -------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                   | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_iam_policy.s3_sqs_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                 | resource    |
| [aws_iam_policy.s3_to_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                     | resource    |
| [aws_iam_role.customer_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                     | resource    |
| [aws_iam_role_policy_attachment.s3_sqs_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_s3_bucket_notification.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification)                  | resource    |
| [aws_s3_bucket_policy.allow_publish_to_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)              | resource    |
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue)                                             | resource    |
| [aws_sqs_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue)                                            | resource    |
| [aws_sqs_queue_redrive_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_policy)              | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                          | data source |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)            | data source |
| [aws_iam_policy_document.sqs_consumer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)             | data source |
| [aws_iam_policy_document.sqs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)               | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                            | data source |

## Inputs

| Name                                                                                                                                 | Description                                                                                            | Type           | Default                                           | Required |
| ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------ | -------------- | ------------------------------------------------- | :------: |
| <a name="input_queue_name"></a> [queue_name](#input_queue_name)                                                                      | Name of the SQS queue to create                                                                        | `string`       | n/a                                               |   yes    |
| <a name="input_s3_bucket_arn"></a> [s3_bucket_arn](#input_s3_bucket_arn)                                                             | The ARN of the S3 bucket                                                                               | `string`       | n/a                                               |   yes    |
| <a name="input_s3_bucket_id"></a> [s3_bucket_id](#input_s3_bucket_id)                                                                | The ID of the S3 bucket to configure event notifications for                                           | `string`       | n/a                                               |   yes    |
| <a name="input_clickhouse_role_arn"></a> [clickhouse_role_arn](#input_clickhouse_role_arn)                                           | The ARN of the ClickHouse role that will be allowed to assume the customer role                        | `string`       | `""`                                              |    no    |
| <a name="input_cloudquery_platform_role_arn"></a> [cloudquery_platform_role_arn](#input_cloudquery_platform_role_arn)                | The ARN of the CloudQuery Platform role that will be allowed to assume the customer role               | `string`       | `""`                                              |    no    |
| <a name="input_cloudquery_role_arn"></a> [cloudquery_role_arn](#input_cloudquery_role_arn)                                           | The ARN of the CloudQuery Platform role that will be allowed to assume the customer role               | `string`       | `""`                                              |    no    |
| <a name="input_content_based_deduplication"></a> [content_based_deduplication](#input_content_based_deduplication)                   | Enables content-based deduplication for FIFO queues                                                    | `bool`         | `false`                                           |    no    |
| <a name="input_create_consumer_policy"></a> [create_consumer_policy](#input_create_consumer_policy)                                  | Whether to create an IAM policy for consumers of this SQS queue                                        | `bool`         | `true`                                            |    no    |
| <a name="input_customer_role_name"></a> [customer_role_name](#input_customer_role_name)                                              | Name of the IAM role to create in the customer's account                                               | `string`       | `"s3-sqs-integration-role"`                       |    no    |
| <a name="input_deduplication_scope"></a> [deduplication_scope](#input_deduplication_scope)                                           | Specifies whether message deduplication occurs at the message group or queue level                     | `string`       | `"queue"`                                         |    no    |
| <a name="input_delay_seconds"></a> [delay_seconds](#input_delay_seconds)                                                             | The time in seconds that the delivery of all messages in the queue will be delayed                     | `number`       | `0`                                               |    no    |
| <a name="input_dlq_max_receive_count"></a> [dlq_max_receive_count](#input_dlq_max_receive_count)                                     | The number of times a message can be unsuccessfully dequeued before being moved to the DLQ             | `number`       | `5`                                               |    no    |
| <a name="input_dlq_message_retention_seconds"></a> [dlq_message_retention_seconds](#input_dlq_message_retention_seconds)             | The number of seconds Amazon SQS retains a message in the DLQ                                          | `number`       | `1209600`                                         |    no    |
| <a name="input_enable_dlq"></a> [enable_dlq](#input_enable_dlq)                                                                      | Whether to create a dead-letter queue                                                                  | `bool`         | `false`                                           |    no    |
| <a name="input_existing_bucket_policy"></a> [existing_bucket_policy](#input_existing_bucket_policy)                                  | The existing bucket policy to merge with the S3 notification policy (in JSON format)                   | `string`       | `"{\"Version\":\"2012-10-17\",\"Statement\":[]}"` |    no    |
| <a name="input_external_id"></a> [external_id](#input_external_id)                                                                   | The external ID to use for role assumption (recommended for security)                                  | `string`       | `""`                                              |    no    |
| <a name="input_fifo_queue"></a> [fifo_queue](#input_fifo_queue)                                                                      | Boolean designating a FIFO queue                                                                       | `bool`         | `false`                                           |    no    |
| <a name="input_fifo_throughput_limit"></a> [fifo_throughput_limit](#input_fifo_throughput_limit)                                     | Specifies whether the FIFO queue throughput quota applies to the entire queue or per message group     | `string`       | `"perQueue"`                                      |    no    |
| <a name="input_filter_prefix"></a> [filter_prefix](#input_filter_prefix)                                                             | Optional prefix filter for S3 notifications                                                            | `string`       | `""`                                              |    no    |
| <a name="input_filter_suffix"></a> [filter_suffix](#input_filter_suffix)                                                             | Optional suffix filter for S3 notifications                                                            | `string`       | `""`                                              |    no    |
| <a name="input_iam_policy_name"></a> [iam_policy_name](#input_iam_policy_name)                                                       | Name of the IAM policy to create for SQS queue consumers                                               | `string`       | `"s3-to-sqs-consumer-policy"`                     |    no    |
| <a name="input_iam_role_name"></a> [iam_role_name](#input_iam_role_name)                                                             | Name of the IAM role to create for S3 and SQS access                                                   | `string`       | `"s3-sqs-integration-role"`                       |    no    |
| <a name="input_kms_data_key_reuse_period_seconds"></a> [kms_data_key_reuse_period_seconds](#input_kms_data_key_reuse_period_seconds) | The length of time in seconds for which Amazon SQS can reuse a data key to encrypt or decrypt messages | `number`       | `300`                                             |    no    |
| <a name="input_kms_master_key_id"></a> [kms_master_key_id](#input_kms_master_key_id)                                                 | The ID of an AWS-managed customer master key for Amazon SQS or a custom CMK                            | `string`       | `null`                                            |    no    |
| <a name="input_max_message_size"></a> [max_message_size](#input_max_message_size)                                                    | The limit of how many bytes a message can contain                                                      | `number`       | `262144`                                          |    no    |
| <a name="input_message_retention_seconds"></a> [message_retention_seconds](#input_message_retention_seconds)                         | The number of seconds Amazon SQS retains a message                                                     | `number`       | `345600`                                          |    no    |
| <a name="input_receive_wait_time_seconds"></a> [receive_wait_time_seconds](#input_receive_wait_time_seconds)                         | The time for which a ReceiveMessage call will wait for a message to arrive                             | `number`       | `0`                                               |    no    |
| <a name="input_require_external_id"></a> [require_external_id](#input_require_external_id)                                           | Whether to require an external ID when assuming the role                                               | `bool`         | `true`                                            |    no    |
| <a name="input_s3_events"></a> [s3_events](#input_s3_events)                                                                         | List of S3 events to trigger notifications for                                                         | `list(string)` | <pre>[<br/> "s3:ObjectCreated:*"<br/>]</pre>      |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                        | A map of tags to assign to resources                                                                   | `map(string)`  | `{}`                                              |    no    |
| <a name="input_visibility_timeout_seconds"></a> [visibility_timeout_seconds](#input_visibility_timeout_seconds)                      | The visibility timeout for the queue in seconds                                                        | `number`       | `30`                                              |    no    |

## Outputs

| Name                                                                                                  | Description                                                        |
| ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| <a name="output_bucket_notification_id"></a> [bucket_notification_id](#output_bucket_notification_id) | The ID of the S3 bucket notification configuration                 |
| <a name="output_customer_role_arn"></a> [customer_role_arn](#output_customer_role_arn)                | ARN of the IAM role created for CloudQuery/ClickHouse integration  |
| <a name="output_customer_role_name"></a> [customer_role_name](#output_customer_role_name)             | Name of the IAM role created for CloudQuery/ClickHouse integration |
| <a name="output_external_id"></a> [external_id](#output_external_id)                                  | External ID used for role assumption (if provided)                 |
| <a name="output_iam_policy_arn"></a> [iam_policy_arn](#output_iam_policy_arn)                         | The ARN of the IAM policy for consumers                            |
| <a name="output_iam_policy_id"></a> [iam_policy_id](#output_iam_policy_id)                            | The ID of the IAM policy for consumers                             |
| <a name="output_iam_policy_name"></a> [iam_policy_name](#output_iam_policy_name)                      | The name of the IAM policy for consumers                           |
| <a name="output_sqs_dlq_arn"></a> [sqs_dlq_arn](#output_sqs_dlq_arn)                                  | The ARN of the SQS dead-letter queue                               |
| <a name="output_sqs_dlq_id"></a> [sqs_dlq_id](#output_sqs_dlq_id)                                     | The ID of the SQS dead-letter queue                                |
| <a name="output_sqs_dlq_url"></a> [sqs_dlq_url](#output_sqs_dlq_url)                                  | The URL of the SQS dead-letter queue                               |
| <a name="output_sqs_queue_arn"></a> [sqs_queue_arn](#output_sqs_queue_arn)                            | The ARN of the SQS queue                                           |
| <a name="output_sqs_queue_id"></a> [sqs_queue_id](#output_sqs_queue_id)                               | The ID of the SQS queue                                            |
| <a name="output_sqs_queue_url"></a> [sqs_queue_url](#output_sqs_queue_url)                            | The URL of the SQS queue                                           |

<!-- END_TF_DOCS -->

## Security Best Practices

- Always use an External ID in the trust policy for cross-account access
- Use a separate IAM role specific to these integrations
- Consider setting up S3 event notifications with prefix filtering to limit the scope
- Use a randomly generated External ID rather than a static value
