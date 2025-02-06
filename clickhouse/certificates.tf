# Generate CA private key
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = var.ssl_key_bits
}

# Generate CA certificate
resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name = "${var.internal_domain} CA"
  }

  validity_period_hours = var.ssl_cert_days * 24
  is_ca_certificate    = true

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}
