provider "aws" {
  region = "us-west-2"
}

resource "aws_acm_certificate" "clickhouse" {
  domain_name       = "clickhouse.mnorbury.me"
  validation_method = "DNS"
}

module "secure_clickhouse" {
  source = "../../" # Adjust based on your module path

  # Enable encryption features
  enable_encryption = true
  enable_nlb        = true
  nlb_type          = "external" # or "external" if you need public access

  # Domain configuration
  cluster_domain = aws_acm_certificate.clickhouse.domain_name

  # If you have an existing ACM certificate
  tls_certificate_arn = aws_acm_certificate.clickhouse.arn

  # SSL certificate configuration (for node-to-node communication)
  ssl_cert_days = 365
  ssl_key_bits  = 4096

  # Cluster configuration
  cluster_name       = "mnorbury-clickhouse"
  cluster_node_count = 3
  keeper_node_count  = 3 # Must be odd number for quorum

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

  shards = [
    {
      replica_count = 3
      weight        = 1 # Higher weight for newer, more powerful nodes
    },
    {
      replica_count = 3
      weight        = 1
    },
  ]

  # Additional optional settings
  tags = {
    Environment = "production"
    Project     = "data-warehouse"
    Security    = "encrypted"
  }
}
