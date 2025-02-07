provider "aws" {
  region = "us-east-1"
}

module "secure_clickhouse" {
  source = "../../" # Adjust based on your module path

  # Enable encryption features
  enable_encryption = true
  enable_nlb        = true
  nlb_type          = "internal" # or "external" if you need public access

  # Domain configuration
  cluster_domain = "clickhouse.example.com"

  # If you have an existing ACM certificate
  tls_certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/abcd1234-ef56-gh78-ij90-klmnopqrstuv"

  # SSL certificate configuration (for node-to-node communication)
  ssl_cert_days = 365
  ssl_key_bits  = 4096

  # Cluster configuration
  cluster_name       = "secure-clickhouse"
  keeper_node_count  = 3 # Must be odd number for quorum

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

  # Instance types
  clickhouse_instance_type = "r5.xlarge"
  keeper_instance_type     = "t3.large"

  # Storage configuration
  clickhouse_volume_size = 100
  clickhouse_volume_type = "gp3"
  keeper_volume_size     = 20
  keeper_volume_type     = "gp3"

  # AWS specific settings
  region = "us-west-2"

  # Additional optional settings
  tags = {
    Environment = "production"
    Project     = "data-warehouse"
    Security    = "encrypted"
  }
}
