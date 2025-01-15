resource "aws_route53_zone" "private" {
  name = local.internal_domain
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "clickhouse_cluster" {
  for_each = local.cluster_nodes
  zone_id  = aws_route53_zone.private.zone_id
  name     = each.value.name
  type     = "A"
  ttl      = 60
  records  = [module.clickhouse_cluster[each.key].private_ip]
}

resource "aws_route53_record" "clickhouse_keeper" {
  for_each = local.keeper_nodes
  zone_id  = aws_route53_zone.private.zone_id
  name     = each.value.name
  type     = "A"
  ttl      = 60
  records  = [module.clickhouse_keeper[each.key].private_ip]
}
