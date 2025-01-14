provider "aws" {
  # Configuration options
  region = var.region

  default_tags {
    tags = {
      Project = "ClickHouse Cluster"
    }
  }
}
