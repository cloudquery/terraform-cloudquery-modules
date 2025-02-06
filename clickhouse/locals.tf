locals {
  name = "${var.cluster_name}-vpc"

  vpc_cidr        = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + length(local.public_subnets))]

  internal_domain = "${var.cluster_name}.internal"

  validate_nlb_tls = (
    !var.enable_nlb_tls ||                                                              # NLB TLS is disabled, no validation needed
    (var.enable_nlb_tls && var.tls_certificate_arn != "" && !var.use_generated_cert) || # Using provided cert
    (var.enable_nlb_tls && var.use_generated_cert && var.enable_encryption)             # Using generated cert with cluster encryption
  )
  validate_nlb_tls_check = regex("^$", (!local.validate_nlb_tls ? "Invalid NLB TLS configuration" : ""))

  # Calculate total nodes needed
  total_replicas = sum([for shard in var.shards : shard.replica_count])

  validate_external_certs = (
    !var.use_external_certs ||                                                                                              # Not using external certs, no validation needed
    (var.use_external_certs && var.enable_encryption && var.external_ca_cert != "" && var.external_cert_secret_ids != null) # Using external certs with all required inputs
  )
  validate_external_certs_check = regex("^$", (!local.validate_external_certs ? "Invalid external certificate configuration" : ""))


  # Create a map of all cluster nodes with their shard and replica information
  cluster_nodes = merge([
    for shard_index, shard in var.shards : {
      for replica_index in range(shard.replica_count) :
      "${var.cluster_name}-cluster-s${shard_index + 1}r${replica_index + 1}" => {
        id            = "${shard_index + 1}-${replica_index + 1}"
        name          = "${var.cluster_name}-cluster-s${shard_index + 1}r${replica_index + 1}"
        host          = "${var.cluster_name}-cluster-s${shard_index + 1}r${replica_index + 1}.${local.internal_domain}"
        shard_index   = shard_index + 1
        replica_index = replica_index + 1
        subnet_index  = (shard_index * shard.replica_count + replica_index) % length(local.private_subnets)
      }
    }
  ]...)

  # Create shard configuration for the remote-servers.xml template
  shard_hosts = {
    for shard_index, shard in var.shards : shard_index + 1 => {
      weight = shard.weight
      replicas = [
        for replica_index in range(shard.replica_count) : {
          host = "${var.cluster_name}-cluster-s${shard_index + 1}r${replica_index + 1}.${local.internal_domain}"
        }
      ]
    }
  }

  # Keeper nodes configuration (remains unchanged)
  keeper_nodes = {
    for i in range(var.keeper_node_count) : "${var.cluster_name}-keeper-${i + 1}" => {
      id           = i + 1
      name         = "${var.cluster_name}-keeper-${i + 1}"
      host         = "${var.cluster_name}-keeper-${i + 1}.${local.internal_domain}"
      subnet_index = i % length(local.private_subnets)
    }
  }
}
