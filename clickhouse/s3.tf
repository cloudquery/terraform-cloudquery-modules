resource "aws_s3_bucket" "configuration" {
  bucket_prefix = "clickhouse"
  force_destroy = true
}

resource "aws_s3_object" "cluster_network_configuration" {
  count  = length(local.azs)
  bucket = aws_s3_bucket.configuration.bucket
  key    = "clickhouse_${count.index + 1}/config.d/network-and-logging.xml"
  content = templatefile("${path.module}/config/server/network-and-logging.xml.tpl", {
    server_id    = count.index + 1
    cluster_name = var.cluster_name
    node_name    = "clickhouse_cluster_${count.index + 1}"
  })
}

resource "random_password" "cluster_secret" {
  length  = 8
  special = false
}

resource "aws_s3_object" "cluster_remote_server_configuration" {
  count  = length(local.azs)
  bucket = aws_s3_bucket.configuration.bucket
  key    = "clickhouse_${count.index + 1}/config.d/remote-servers.xml"
  content = templatefile("${path.module}/config/server/remote-servers.xml.tpl", {
    server_id      = count.index + 1
    cluster_name   = var.cluster_name
    cluster_secret = random_password.cluster_secret.result
    replica_hosts  = aws_route53_record.clickhouse_cluster[*].fqdn
  })
}

resource "aws_s3_object" "cluster_use_keeper_configuration" {
  count  = length(local.azs)
  bucket = aws_s3_bucket.configuration.bucket
  key    = "clickhouse_${count.index + 1}/config.d/use-keeper.xml"
  content = templatefile("${path.module}/config/server/use-keeper.xml.tpl", {
    keeper_nodes = aws_route53_record.clickhouse_keeper[*].fqdn
  })
}

resource "aws_s3_object" "cluster_macros" {
  count  = length(local.azs)
  bucket = aws_s3_bucket.configuration.bucket
  key    = "clickhouse_${count.index + 1}/config.d/macros.xml"
  content = templatefile("${path.module}/config/server/macros.xml.tpl", {
    cluster_name = var.cluster_name
    shard_id     = 1
    replica_id   = count.index + 1
  })
}

resource "aws_s3_object" "cluster_cloudwatch_configuration" {
  count  = length(local.azs)
  bucket = aws_s3_bucket.configuration.bucket
  key    = "clickhouse_${count.index + 1}/cloudwatch.json"
  content = templatefile("${path.module}/config/cloudwatch.json.tpl", {
    log_group  = aws_cloudwatch_log_group.clickhouse.name
    log_name   = "ClickHouseServer"
    mount_path = "/var/lib/clickhouse"
    file_path  = "/var/log/clickhouse-server/clickhouse-server.log"
  })
}

resource "aws_s3_object" "keeper_configuration" {
  count  = length(local.azs)
  bucket = aws_s3_bucket.configuration.bucket
  key    = "keeper_${count.index + 1}/keeper_config.xml"
  content = templatefile("${path.module}/config/keeper/keeper_config.xml.tpl", {
    server_id = count.index + 1
  })
}

resource "aws_s3_object" "keeper_cloudwatch_configuration" {
  count  = length(local.azs)
  bucket = aws_s3_bucket.configuration.bucket
  key    = "keeper_${count.index + 1}/cloudwatch.json"
  content = templatefile("${path.module}/config/cloudwatch.json.tpl", {
    log_group  = aws_cloudwatch_log_group.keeper.name
    log_name   = "ClickHouseKeeper"
    mount_path = "/data"
    file_path  = "/var/log/clickhouse-keeper/clickhouse-keeper.log"
  })
}
