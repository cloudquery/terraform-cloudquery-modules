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

module "bastion" {
  count   = var.enable_bastion ? 1 : 0
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.1"

  name = "bastion"
  ami  = data.aws_ami.ubuntu.id

  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = module.vpc.public_subnets[0]
}

module "clickhouse_cluster" {
  count   = length(local.azs)
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.1"

  name                 = "clickhouse_cluster_${count.index + 1}"
  iam_instance_profile = aws_iam_instance_profile.clickhouse_cluster_profile.name
  ami                  = data.aws_ami.ubuntu.id

  instance_type          = var.clickhouse_instance_type
  vpc_security_group_ids = [aws_security_group.clickhouse_cluster.id]
  subnet_id              = module.vpc.private_subnets[count.index]
  user_data = templatefile("${path.module}/scripts/install_clickhouse.sh.tpl", {
    server_id                = count.index + 1,
    clickhouse_server        = true,
    clickhouse_config_bucket = aws_s3_bucket.configuration.bucket
  })

  metadata_options = {
    http_endpoint               = "enabled"  # Enable IMDS
    http_tokens                 = "required" # IMDSv2 (more secure)
    http_put_response_hop_limit = 1          # Restrict token usage
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
  count   = length(local.azs)
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.1"

  name                 = "clickhouse_keeper_${count.index + 1}"
  iam_instance_profile = aws_iam_instance_profile.clickhouse_cluster_profile.name
  ami                  = data.aws_ami.ubuntu.id

  instance_type          = var.keeper_instance_type
  vpc_security_group_ids = [aws_security_group.clickhouse_keeper.id]
  subnet_id              = module.vpc.private_subnets[count.index]
  user_data = templatefile("${path.module}/scripts/install_clickhouse.sh.tpl", {
    server_id                = count.index + 1,
    clickhouse_server        = false,
    clickhouse_config_bucket = aws_s3_bucket.configuration.bucket
  })

  metadata_options = {
    http_endpoint               = "enabled"  # Enable IMDS
    http_tokens                 = "required" # IMDSv2 (more secure)
    http_put_response_hop_limit = 1          # Restrict token usage
    instance_metadata_tags      = "enabled"  # Allow tag access
  }

  # The keepers depend on the nat gateways being created
  depends_on = [
    module.vpc,
    aws_s3_object.keeper_configuration,
    aws_ebs_volume.keeper
  ]
}

