// Output the public and private IP addresses of the ClickHouse cluster
output "clickhouse_cluster_ips" {
  value = { for k, v in local.cluster_nodes : k => {
    id : module.clickhouse_cluster[k].id
    public : module.clickhouse_cluster[k].public_ip
    private : module.clickhouse_cluster[k].private_ip
    }
  }
}

// Output the public and private IP addresses of the ClickHouse keepers
output "clickhouse_keeper_ips" {
  value = { for k, v in local.keeper_nodes : k => {
    id : module.clickhouse_keeper[k].id
    public : module.clickhouse_keeper[k].public_ip
    private : module.clickhouse_keeper[k].private_ip
    }
  }
}


// Output the DNS name of the NLB
output "clickhouse_nlb_dns" {
  value = var.enable_nlb ? aws_lb.nlb[0].dns_name : ""
}

# Output the Secret ARN for use in user_data
output "ca_secret_arn" {
  value = var.enable_encryption ? aws_secretsmanager_secret.ca_materials[0].arn : ""
}
