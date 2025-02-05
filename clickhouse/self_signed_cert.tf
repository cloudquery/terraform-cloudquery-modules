resource "tls_private_key" "clickhouse" {
  count     = var.enable_encryption && var.use_self_signed_cert ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = var.ssl_key_bits
}

resource "tls_self_signed_cert" "clickhouse" {
  count           = var.enable_encryption && var.use_self_signed_cert ? 1 : 0
  private_key_pem = tls_private_key.clickhouse[0].private_key_pem

  subject {
    common_name  = coalesce(var.cluster_domain, "clickhouse.internal")
    organization = "ClickHouse Cluster"
  }

  validity_period_hours = var.ssl_cert_days * 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = compact([
    coalesce(var.cluster_domain, "clickhouse.internal"),
    "*.clickhouse.internal",
    var.enable_nlb ? aws_lb.nlb[0].dns_name : ""
  ])
}

resource "aws_acm_certificate" "clickhouse" {
  count            = var.enable_encryption && var.use_self_signed_cert ? 1 : 0
  private_key      = tls_private_key.clickhouse[0].private_key_pem
  certificate_body = tls_self_signed_cert.clickhouse[0].cert_pem
}
