module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets


  enable_nat_gateway     = true
  enable_vpn_gateway     = false
  one_nat_gateway_per_az = false

  # Enable DNS hostnames for the VPC
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "clickhouse_cluster" {
  for_each = local.cluster_nodes
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "5.7.1"

  name                 = each.key
  iam_instance_profile = aws_iam_instance_profile.clickhouse_cluster_profile.name
  ami                  = data.aws_ami.ubuntu.id
  key_name             = var.key_name != "" ? var.key_name : null

  instance_type               = var.clickhouse_instance_type
  vpc_security_group_ids      = [aws_security_group.clickhouse_cluster.id]
  subnet_id                   = module.vpc.private_subnets[each.value.subnet_index]
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/scripts/install_clickhouse.sh.tpl", {
    node_name                = each.value.name,
    clickhouse_server        = true,
    clickhouse_config_bucket = aws_s3_bucket.configuration.bucket,
    enable_encryption        = var.enable_encryption,
    internal_domain          = local.internal_domain,
    use_external_certs       = var.use_external_certs
    external_ca_cert         = var.use_external_certs ? var.external_ca_cert : ""
    ca_secret_arn            = !var.enable_encryption || var.use_external_certs ? "" : aws_secretsmanager_secret.ca_materials[0].arn
    node_secret_arn          = var.use_external_certs ? var.external_cert_secret_ids.cluster_nodes[each.key] : var.enable_encryption ? aws_secretsmanager_secret.node_certs[each.key].arn : ""
  })

  metadata_options = {
    http_endpoint               = "enabled"  # Enable IMDS
    http_tokens                 = "required" # IMDSv2 (more secure)
    http_put_response_hop_limit = 2          # Restrict token usage
    instance_metadata_tags      = "enabled"  # Allow tag access
  }

  # The cluster depends on the nat gateways being created
  depends_on = [
    module.vpc,
    aws_s3_object.cluster_network_configuration,
    aws_ebs_volume.clickhouse
  ]
}

module "clickhouse_keeper" {
  for_each = local.keeper_nodes
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "5.7.1"

  name                 = each.key
  iam_instance_profile = aws_iam_instance_profile.clickhouse_cluster_profile.name
  ami                  = data.aws_ami.ubuntu.id
  key_name             = var.key_name != "" ? var.key_name : null

  instance_type               = var.keeper_instance_type
  vpc_security_group_ids      = [aws_security_group.clickhouse_keeper.id]
  subnet_id                   = module.vpc.private_subnets[each.value.subnet_index]
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/scripts/install_clickhouse.sh.tpl", {
    node_name                = each.value.name,
    clickhouse_server        = false,
    clickhouse_config_bucket = aws_s3_bucket.configuration.bucket,
    enable_encryption        = var.enable_encryption,
    internal_domain          = local.internal_domain,
    use_external_certs       = var.use_external_certs
    external_ca_cert         = var.use_external_certs ? var.external_ca_cert : ""
    ca_secret_arn            = !var.enable_encryption || var.use_external_certs ? "" : aws_secretsmanager_secret.ca_materials[0].arn
    node_secret_arn          = var.use_external_certs ? var.external_cert_secret_ids.keeper_nodes[each.key] : var.enable_encryption ? aws_secretsmanager_secret.node_certs[each.key].arn : ""
  })

  metadata_options = {
    http_endpoint               = "enabled"  # Enable IMDS
    http_tokens                 = "required" # IMDSv2 (more secure)
    http_put_response_hop_limit = 2          # Restrict token usage
    instance_metadata_tags      = "enabled"  # Allow tag access
  }

  # The keepers depend on the nat gateways being created
  depends_on = [
    module.vpc,
    aws_s3_object.keeper_configuration,
    aws_ebs_volume.keeper
  ]
}
