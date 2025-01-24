locals {
  name = "clickhouse-vpc"

  vpc_cidr        = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + length(local.public_subnets))]

  internal_domain = "clickhouse.internal"

  cluster_nodes = {
    for i in range(var.cluster_node_count) : "clickhouse_cluster_${i + 1}" => {
      id           = i + 1
      name         = "clickhouse_cluster_${i + 1}"
      host         = "clickhouse_cluster_${i + 1}.${local.internal_domain}"
      subnet_index = i % length(local.private_subnets)
    }
  }

  keeper_nodes = {
    for i in range(var.keeper_node_count) : "clickhouse_keeper_${i + 1}" => {
      id           = i + 1
      name         = "clickhouse_keeper_${i + 1}"
      host         = "clickhouse_keeper_${i + 1}.${local.internal_domain}"
      subnet_index = i % length(local.private_subnets)
    }
  }
}
