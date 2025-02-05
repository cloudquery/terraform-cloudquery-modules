resource "aws_cloudwatch_log_group" "clickhouse" {
  name_prefix = "${var.name_prefix}clickhouse-"
}

resource "aws_cloudwatch_log_group" "keeper" {
  name_prefix = "${var.name_prefix}keeper-"
}
