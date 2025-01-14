resource "aws_cloudwatch_log_group" "clickhouse" {
  name_prefix = "clickhouse-"
}

resource "aws_cloudwatch_log_group" "keeper" {
  name_prefix = "keeper-"
}
