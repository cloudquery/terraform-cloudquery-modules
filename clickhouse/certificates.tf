# Generate CA private key
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = var.ssl_key_bits
}

# Generate CA certificate
resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name = "${var.cluster_domain} CA"
  }

  validity_period_hours = var.ssl_cert_days * 24
  is_ca_certificate     = true

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

# Generate server private key
resource "tls_private_key" "server" {
  for_each  = local.keeper_nodes
  algorithm = "RSA"
  rsa_bits  = var.ssl_key_bits
}

# Generate server CSR
resource "tls_cert_request" "server" {
  for_each        = local.keeper_nodes
  private_key_pem = tls_private_key.server[each.key].private_key_pem

  subject {
    common_name = each.value.host
  }

  dns_names = [
    var.enable_nlb ? aws_lb.nlb[0].dns_name : "",
    each.value.host,
  ]
}

# Generate server certificate
resource "tls_locally_signed_cert" "server" {
  for_each           = local.keeper_nodes
  cert_request_pem   = tls_cert_request.server[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.ssl_cert_days * 24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}