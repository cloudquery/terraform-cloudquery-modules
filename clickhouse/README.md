# CloudQuery ClickHouse Terraform Module

## Overview

Installs clickhouse-server and clickhouse-keeper to provide a ClickHouse cluster with replication enabled. Access is via a public-facing NLB. Currently only a single shard is used.

## Architecture

Architecture for a self-hosted clickhouse install supporting [replication](https://clickhouse.com/docs/en/architecture/replication).

![ClickHouse Architecutre](./docs/clickhouse_architecture.png)

## Testing

The following can be used to insert some data for testing purposes. Note the use of `on cluster <cluster-name>` in the database and table creation steps. Clickhouse Cloud abstracts this away from users.

- Create a database

```sql
create database db1 on cluster clickhouse_cluster;
```

- Create a table

```sql
CREATE TABLE db1.table1 ON CLUSTER clickhouse_cluster
(  
`id` UInt64,  
`column1` String  
)  
ENGINE = ReplicatedMergeTree  
ORDER BY id
```

- Insert some data

```sql
INSERT INTO db1.table1 (id, column1) VALUES (1, 'abc');
```

At this stage the data should be present on all nodes of the cluster given that is it configured as a single shard + n replica cluster.

## TODO

- [ ] Add CI/CD for validating and documenting Terraform
- [ ] Add a default user with a password
- [ ] Add certificates to the ClickHouse server
- [ ] Add support for [sharding](https://clickhouse.com/docs/en/architecture/horizontal-scaling)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.82.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_clickhouse_cluster"></a> [clickhouse\_cluster](#module\_clickhouse\_cluster) | terraform-aws-modules/ec2-instance/aws | 5.7.1 |
| <a name="module_clickhouse_keeper"></a> [clickhouse\_keeper](#module\_clickhouse\_keeper) | terraform-aws-modules/ec2-instance/aws | 5.7.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.17.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.clickhouse](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/cloudwatch_log_group) | resource |
| [aws_ebs_volume.clickhouse](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/ebs_volume) | resource |
| [aws_ebs_volume.keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/ebs_volume) | resource |
| [aws_flow_log.vpc](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/flow_log) | resource |
| [aws_iam_instance_profile.clickhouse_cluster_profile](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.clickhouse_keeper_profile](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.s3_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.clickhouse_role](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_role) | resource |
| [aws_iam_role.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cw_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.kms_policy](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/kms_key) | resource |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/lb) | resource |
| [aws_lb_listener.clickhouse_nlb_listener](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.clickhouse_nlb_target_group](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.clickhouse_nlb_target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/lb_target_group_attachment) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.private_egress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/network_acl_rule) | resource |
| [aws_route53_record.clickhouse_cluster](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/route53_record) | resource |
| [aws_route53_record.clickhouse_keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/route53_record) | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_public_access_block.configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.cluster_cloudwatch_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.cluster_macros](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.cluster_network_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.cluster_remote_server_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.cluster_s3_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.cluster_use_keeper_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.cluster_users_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.keeper_cloudwatch_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_s3_object.keeper_configuration](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/s3_object) | resource |
| [aws_secretsmanager_secret.clickhouse_credentials](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.clickhouse_credentials](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.clickhouse_cluster](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group) | resource |
| [aws_security_group.clickhouse_keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group) | resource |
| [aws_security_group.nlb](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group) | resource |
| [aws_security_group_rule.clickhouse_egress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.clickhouse_healthcheck](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.clickhouse_ingress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.clickhouse_nlb_ingress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.clickhouse_secure_ingress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_allow_all_outbound](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_cluster_to_keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.keeper_allow_all_outbound](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.keeper_cluster_to_keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.keeper_egress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.keeper_ingress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nlb_clickhouse_egress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nlb_ingress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nlb_secure_ingress](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/security_group_rule) | resource |
| [aws_volume_attachment.clickhouse](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.keeper](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/volume_attachment) | resource |
| [random_password.admin_user](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) | resource |
| [random_password.cluster_secret](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) | resource |
| [random_password.default_user](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_user_networks"></a> [admin\_user\_networks](#input\_admin\_user\_networks) | List of networks allowed to connect as admin user | `list(string)` | <pre>[<br/>  "::/0"<br/>]</pre> | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks allowed to access the ClickHouse cluster | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_clickhouse_instance_type"></a> [clickhouse\_instance\_type](#input\_clickhouse\_instance\_type) | The instance type for the ClickHouse servers | `string` | `"t2.medium"` | no |
| <a name="input_clickhouse_volume_size"></a> [clickhouse\_volume\_size](#input\_clickhouse\_volume\_size) | The size of the EBS volume for the ClickHouse servers in GB | `number` | `10` | no |
| <a name="input_clickhouse_volume_type"></a> [clickhouse\_volume\_type](#input\_clickhouse\_volume\_type) | The type of EBS volume for the ClickHouse servers | `string` | `"gp2"` | no |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | Domain name for the cluster (used for certificates) | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the ClickHouse cluster | `string` | `"clickhouse_cluster"` | no |
| <a name="input_cluster_node_count"></a> [cluster\_node\_count](#input\_cluster\_node\_count) | The number of ClickHouse servers to deploy | `number` | `3` | no |
| <a name="input_default_user_networks"></a> [default\_user\_networks](#input\_default\_user\_networks) | List of networks allowed to connect as default user | `list(string)` | <pre>[<br/>  "::/0"<br/>]</pre> | no |
| <a name="input_enable_encryption"></a> [enable\_encryption](#input\_enable\_encryption) | Enable TLS encryption for all ClickHouse communication | `bool` | `false` | no |
| <a name="input_enable_nlb"></a> [enable\_nlb](#input\_enable\_nlb) | Enable the Network Load Balancer for the ClickHouse cluster | `bool` | `true` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | HTTP default port | `number` | `8123` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | HTTPS default port | `number` | `8443` | no |
| <a name="input_interserver_http_port"></a> [interserver\_http\_port](#input\_interserver\_http\_port) | Inter-server communication port | `number` | `9009` | no |
| <a name="input_interserver_https_port"></a> [interserver\_https\_port](#input\_interserver\_https\_port) | SSL/TLS port for inter-server communications | `number` | `9010` | no |
| <a name="input_keeper_instance_type"></a> [keeper\_instance\_type](#input\_keeper\_instance\_type) | The instance type for the ClickHouse keepers | `string` | `"t2.medium"` | no |
| <a name="input_keeper_node_count"></a> [keeper\_node\_count](#input\_keeper\_node\_count) | The number of ClickHouse keepers to deploy | `number` | `3` | no |
| <a name="input_keeper_port"></a> [keeper\_port](#input\_keeper\_port) | ClickHouse Keeper port | `number` | `9181` | no |
| <a name="input_keeper_port_secure"></a> [keeper\_port\_secure](#input\_keeper\_port\_secure) | Secure SSL ClickHouse Keeper port | `number` | `9281` | no |
| <a name="input_keeper_raft_port"></a> [keeper\_raft\_port](#input\_keeper\_raft\_port) | ClickHouse Keeper Raft port | `number` | `9234` | no |
| <a name="input_keeper_volume_size"></a> [keeper\_volume\_size](#input\_keeper\_volume\_size) | The size of the EBS volume for the ClickHouse keepers in GB | `number` | `10` | no |
| <a name="input_keeper_volume_type"></a> [keeper\_volume\_type](#input\_keeper\_volume\_type) | The type of EBS volume for the ClickHouse keepers | `string` | `"gp2"` | no |
| <a name="input_nlb_type"></a> [nlb\_type](#input\_nlb\_type) | Type of NLB to create - internal or external | `string` | `"internal"` | no |
| <a name="input_prometheus_port"></a> [prometheus\_port](#input\_prometheus\_port) | Prometheus metrics port | `number` | `9363` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy to | `string` | `"us-west-2"` | no |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | Log retention period in days | `number` | `30` | no |
| <a name="input_shards"></a> [shards](#input\_shards) | List of shards and their configuration. Each shard specifies how many replicas it should have and optionally its weight. | <pre>list(object({<br/>    replica_count = number<br/>    weight        = optional(number, 1)<br/>  }))</pre> | n/a | yes |
| <a name="input_ssl_cert_days"></a> [ssl\_cert\_days](#input\_ssl\_cert\_days) | Validity period for self-signed certificates in days | `number` | `365` | no |
| <a name="input_ssl_key_bits"></a> [ssl\_key\_bits](#input\_ssl\_key\_bits) | Key size for self-signed certificates | `number` | `2048` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "production",<br/>  "ManagedBy": "terraform"<br/>}</pre> | no |
| <a name="input_tcp_port"></a> [tcp\_port](#input\_tcp\_port) | Native Protocol port for client-server communication | `number` | `9000` | no |
| <a name="input_tcp_port_secure"></a> [tcp\_port\_secure](#input\_tcp\_port\_secure) | Native protocol SSL/TLS port | `number` | `9440` | no |
| <a name="input_tls_certificate_arn"></a> [tls\_certificate\_arn](#input\_tls\_certificate\_arn) | ARN of ACM certificate to use for TLS | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_clickhouse_cluster_ips"></a> [clickhouse\_cluster\_ips](#output\_clickhouse\_cluster\_ips) | Output the public and private IP addresses of the ClickHouse cluster |
| <a name="output_clickhouse_keeper_ips"></a> [clickhouse\_keeper\_ips](#output\_clickhouse\_keeper\_ips) | Output the public and private IP addresses of the ClickHouse keepers |
| <a name="output_clickhouse_nlb_dns"></a> [clickhouse\_nlb\_dns](#output\_clickhouse\_nlb\_dns) | Output the DNS name of the NLB |
<!-- END_TF_DOCS -->
