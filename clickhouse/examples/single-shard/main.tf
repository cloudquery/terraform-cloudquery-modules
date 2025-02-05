provider "aws" {
  region = "us-west-2"
}

module "clickhouse_ha" {
  source = "../.."

  # Single shard with 3 replicas for high availability
  shards = [
    {
      replica_count = 3
      weight        = 1
    }
  ]

  # 3 keeper nodes for HA quorum
  keeper_node_count = 3

  # Use more powerful instances for production
  clickhouse_instance_type = "r5.xlarge"
  clickhouse_volume_size   = 100

  # Only allow connections from your network
  allowed_cidr_blocks = ["10.0.0.0/8"]

  cluster_name = "clickhouse-ha"

  tags = {
    Environment = "production"
    Project     = "analytics"
  }
}
