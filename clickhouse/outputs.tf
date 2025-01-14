// Availability Zones - used for debugging
output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

// EC2 instances IP addresses
output "clickhouse_cluster_ips" {
  value = {
    public : module.clickhouse_cluster[*].public_ip
    private : module.clickhouse_cluster[*].private_ip
  }
}
