resource "aws_route53_zone" "private" {
  name = "clickhouse.internal"
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "clickhouse_cluster" {
  count   = length(local.azs)
  zone_id = aws_route53_zone.private.zone_id
  name    = "clickhouse_cluster_${count.index + 1}"
  type    = "A"
  ttl     = 60
  records = [module.clickhouse_cluster[count.index].private_ip]
}

resource "aws_route53_record" "clickhouse_keeper" {
  count   = length(local.azs)
  zone_id = aws_route53_zone.private.zone_id
  name    = "clickhouse_keeper_${count.index + 1}"
  type    = "A"
  ttl     = 60
  records = [module.clickhouse_keeper[count.index].private_ip]
}
