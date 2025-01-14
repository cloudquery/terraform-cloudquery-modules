## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.82.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | terraform-aws-modules/ec2-instance/aws | 5.7.1 |
| <a name="module_clickhouse_cluster"></a> [clickhouse\_cluster](#module\_clickhouse\_cluster) | terraform-aws-modules/ec2-instance/aws | 5.7.1 |
| <a name="module_clickhouse_keeper"></a> [clickhouse\_keeper](#module\_clickhouse\_keeper) | terraform-aws-modules/ec2-instance/aws | 5.7.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.17.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.clickhouse](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/cloudwatch_log_group) | resource |
| [aws_ebs_volume.clickhouse](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/ebs_volume) | resource |
| [aws_ebs_volume.keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/ebs_volume) | resource |
| [aws_iam_instance_profile.clickhouse_cluster_profile](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.clickhouse_keeper_profile](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.s3_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.clickhouse_role](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cw_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_role_policy_attachment) | resource |
| [aws_route53_record.clickhouse_cluster](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/route53_record) | resource |
| [aws_route53_record.clickhouse_keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/route53_record) | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_bucket) | resource |
| [aws_s3_object.cluster_cloudwatch_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.cluster_macros](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.cluster_network_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.cluster_remote_server_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.cluster_use_keeper_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.keeper_cloudwatch_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.keeper_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_security_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group) | resource |
| [aws_security_group.clickhouse_cluster](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group) | resource |
| [aws_security_group.clickhouse_keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group) | resource |
| [aws_security_group_rule.bastion_allow_all_outbound](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.bastion_allow_ssh](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.clickhouse_egress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.clickhouse_ingress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_allow_all_outbound](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_cluster_to_keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.keeper_allow_all_outbound](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.keeper_cluster_to_keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.keeper_egress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.keeper_ingress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_volume_attachment.clickhouse](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/volume_attachment) | resource |
| [random_password.cluster_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clickhouse_instance_type"></a> [clickhouse\_instance\_type](#input\_clickhouse\_instance\_type) | The instance type for the ClickHouse servers | `string` | `"t2.medium"` | no |
| <a name="input_clickhouse_volume_size"></a> [clickhouse\_volume\_size](#input\_clickhouse\_volume\_size) | The size of the EBS volume for the ClickHouse servers | `number` | `10` | no |
| <a name="input_clickhouse_volume_type"></a> [clickhouse\_volume\_type](#input\_clickhouse\_volume\_type) | The type of EBS volume for the ClickHouse servers | `string` | `"gp2"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the ClickHouse cluster | `string` | `"clickhouse_cluster"` | no |
| <a name="input_enable_bastion"></a> [enable\_bastion](#input\_enable\_bastion) | Whether to deploy a bastion host | `bool` | `false` | no |
| <a name="input_keeper_instance_type"></a> [keeper\_instance\_type](#input\_keeper\_instance\_type) | The instance type for the ClickHouse keepers | `string` | `"t2.medium"` | no |
| <a name="input_keeper_volume_size"></a> [keeper\_volume\_size](#input\_keeper\_volume\_size) | The size of the EBS volume for the ClickHouse keepers | `number` | `10` | no |
| <a name="input_keeper_volume_type"></a> [keeper\_volume\_type](#input\_keeper\_volume\_type) | The type of EBS volume for the ClickHouse keepers | `string` | `"gp2"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy to | `string` | `"us-west-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | Availability Zones - used for debugging |
| <a name="output_clickhouse_cluster_ips"></a> [clickhouse\_cluster\_ips](#output\_clickhouse\_cluster\_ips) | EC2 instances IP addresses |
