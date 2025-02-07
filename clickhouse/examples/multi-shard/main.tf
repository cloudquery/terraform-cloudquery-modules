module "clickhouse_multi_shard" {
  source = "../../"

  region = "us-west-2"

  # 3 shards with 2 replicas each for scalability and HA
  shards = [
    {
      replica_count = 2
      weight        = 2 # Higher weight for newer, more powerful nodes
    },
    {
      replica_count = 2
      weight        = 1
    },
    {
      replica_count = 2
      weight        = 1
    }
  ]

  # 3 keeper nodes for HA quorum
  keeper_node_count = 3

  # Use powerful instances for sharded setup
  clickhouse_instance_type = "r5.2xlarge"
  clickhouse_volume_size   = 200

  # Only allow connections from your network
  allowed_cidr_blocks = ["10.0.0.0/8"]

  cluster_name = "clickhouse-multi-shard"

  tags = {
    Environment = "production"
    Project     = "analytics"
  }
}
