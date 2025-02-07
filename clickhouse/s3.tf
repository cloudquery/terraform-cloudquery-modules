resource "aws_s3_bucket" "configuration" {
  bucket_prefix = var.cluster_name
  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "configuration" {
  bucket = aws_s3_bucket.configuration.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "configuration" {
  bucket = aws_s3_bucket.configuration.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "cluster_network_configuration" {
  for_each = local.cluster_nodes
  bucket   = aws_s3_bucket.configuration.bucket
  key      = "${each.value.name}/config.d/network-and-logging.xml"
  content = templatefile("${path.module}/config/server/network-and-logging.xml.tpl", {
    server_id              = each.value.id
    cluster_name           = var.cluster_name
    node_name              = each.value.name
    enable_encryption      = var.enable_encryption
    http_port              = var.http_port
    https_port             = var.https_port
    tcp_port               = var.tcp_port
    tcp_port_secure        = var.tcp_port_secure
    prometheus_port        = var.prometheus_port
    interserver_http_port  = var.interserver_http_port
    interserver_https_port = var.interserver_https_port
  })

  depends_on = [
    aws_s3_bucket.configuration,
    aws_s3_bucket_versioning.configuration
  ]
}

resource "random_password" "cluster_secret" {
  length  = 8
  special = false
}

resource "aws_s3_object" "cluster_remote_server_configuration" {
  for_each = local.cluster_nodes
  bucket   = aws_s3_bucket.configuration.bucket
  key      = "${each.value.name}/config.d/remote-servers.xml"
  content = templatefile("${path.module}/config/server/remote-servers.xml.tpl", {
    cluster_name      = var.cluster_name
    cluster_secret    = random_password.cluster_secret.result
    shard_hosts       = local.shard_hosts
    enable_encryption = var.enable_encryption
    tcp_port          = var.tcp_port
    tcp_port_secure   = var.tcp_port_secure
  })

  depends_on = [
    aws_s3_bucket.configuration,
    aws_s3_bucket_versioning.configuration
  ]
}

resource "aws_s3_object" "cluster_use_keeper_configuration" {
  for_each = local.cluster_nodes
  bucket   = aws_s3_bucket.configuration.bucket
  key      = "${each.value.name}/config.d/use-keeper.xml"
  content = templatefile("${path.module}/config/server/use-keeper.xml.tpl", {
    keeper_nodes       = [for _, record in aws_route53_record.clickhouse_keeper : record.fqdn]
    enable_encryption  = var.enable_encryption
    keeper_port        = var.keeper_port
    keeper_port_secure = var.keeper_port_secure
  })

  depends_on = [
    aws_s3_bucket.configuration,
    aws_s3_bucket_versioning.configuration
  ]
}

resource "aws_s3_object" "cluster_macros" {
  for_each = local.cluster_nodes
  bucket   = aws_s3_bucket.configuration.bucket
  key      = "${each.value.name}/config.d/macros.xml"
  content = templatefile("${path.module}/config/server/macros.xml.tpl", {
    cluster_name  = var.cluster_name
    shard_index   = each.value.shard_index
    replica_index = each.value.replica_index
  })

  depends_on = [
    aws_s3_bucket.configuration,
    aws_s3_bucket_versioning.configuration
  ]
}

resource "aws_s3_object" "cluster_cloudwatch_configuration" {
  for_each = local.cluster_nodes
  bucket   = aws_s3_bucket.configuration.bucket
  key      = "${each.value.name}/cloudwatch.json"
  content = templatefile("${path.module}/config/cloudwatch.json.tpl", {
    log_group  = aws_cloudwatch_log_group.clickhouse.name
    log_name   = "ClickHouseServer"
    mount_path = "/var/lib/clickhouse"
    file_path  = "/var/log/clickhouse-server/clickhouse-server.log"
  })

  depends_on = [
    aws_s3_bucket.configuration,
    aws_s3_bucket_versioning.configuration
  ]
}

resource "aws_s3_object" "keeper_configuration" {
  for_each = local.keeper_nodes
  bucket   = aws_s3_bucket.configuration.bucket
  key      = "${each.value.name}/keeper_config.xml"
  content = templatefile("${path.module}/config/keeper/keeper_config.xml.tpl", {
    server_id          = each.value.id
    keeper_nodes       = local.keeper_nodes
    enable_encryption  = var.enable_encryption
    keeper_port        = var.keeper_port
    keeper_port_secure = var.keeper_port_secure
    keeper_raft_port   = var.keeper_raft_port
  })

  depends_on = [
    aws_s3_bucket.configuration,
    aws_s3_bucket_versioning.configuration
  ]
}

resource "aws_s3_object" "keeper_cloudwatch_configuration" {
  for_each = local.keeper_nodes
  bucket   = aws_s3_bucket.configuration.bucket
  key      = "${each.value.name}/cloudwatch.json"
  content = templatefile("${path.module}/config/cloudwatch.json.tpl", {
    log_group  = aws_cloudwatch_log_group.keeper.name
    log_name   = "ClickHouseKeeper"
    mount_path = "/data"
    file_path  = "/var/log/clickhouse-keeper/clickhouse-keeper.log"
  })

  depends_on = [
    aws_s3_bucket.configuration,
    aws_s3_bucket_versioning.configuration
  ]
}

resource "aws_s3_object" "cluster_users_configuration" {
  for_each = local.cluster_nodes
  bucket   = aws_s3_bucket.configuration.bucket
  key      = "${each.value.name}/users.xml"
  content = templatefile("${path.module}/config/server/users.xml.tpl", {
    default_password_hash = sha256(random_password.default_user.result)
    admin_password_hash   = sha256(random_password.admin_user.result)
    default_allowed_ips   = var.default_user_networks
    admin_allowed_ips     = var.admin_user_networks
  })

  depends_on = [
    aws_s3_bucket.configuration,
    aws_s3_bucket_versioning.configuration
  ]
}

resource "aws_s3_object" "cluster_s3_configuration" {
  for_each = local.cluster_nodes
  bucket   = aws_s3_bucket.configuration.bucket
  key      = "${each.value.name}/config.d/s3.xml"
  content  = file("${path.module}/config/server/s3.xml.tpl")

  depends_on = [
    aws_s3_bucket.configuration,
    aws_s3_bucket_versioning.configuration
  ]
}

resource "aws_s3_bucket_public_access_block" "configuration" {
  bucket = aws_s3_bucket.configuration.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "configuration" {
  bucket = aws_s3_bucket.configuration.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}

# Logging bucket
resource "aws_s3_bucket" "logs" {
  bucket_prefix = "clickhouse-logs"
  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
