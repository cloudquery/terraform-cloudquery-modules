resource "aws_cloudwatch_log_group" "clickhouse" {
  name_prefix = var.cluster_name
}

resource "aws_cloudwatch_log_group" "keeper" {
  name_prefix = "${var.cluster_name}-keeper"
}
