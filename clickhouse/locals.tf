locals {
  name = "clickhouse-vpc"

  vpc_cidr        = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + length(local.public_subnets))]

  internal_domain = "clickhouse.internal"

  # Calculate total nodes needed
  total_replicas = sum([for shard in var.shards : shard.replica_count])

  # Create a map of all cluster nodes with their shard and replica information
  cluster_nodes = merge([
    for shard_index, shard in var.shards : {
      for replica_index in range(shard.replica_count) :
      "clickhouse_cluster_s${shard_index + 1}r${replica_index + 1}" => {
        id            = "${shard_index + 1}-${replica_index + 1}"
        name          = "clickhouse_cluster_s${shard_index + 1}r${replica_index + 1}"
        host          = "clickhouse_cluster_s${shard_index + 1}r${replica_index + 1}.${local.internal_domain}"
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
          host = "clickhouse_cluster_s${shard_index + 1}r${replica_index + 1}.${local.internal_domain}"
        }
      ]
    }
  }

  # Keeper nodes configuration (remains unchanged)
  keeper_nodes = {
    for i in range(var.keeper_node_count) : "clickhouse_keeper_${i + 1}" => {
      id           = i + 1
      name         = "clickhouse_keeper_${i + 1}"
      host         = "clickhouse_keeper_${i + 1}.${local.internal_domain}"
      subnet_index = i % length(local.private_subnets)
    }
  }
}
