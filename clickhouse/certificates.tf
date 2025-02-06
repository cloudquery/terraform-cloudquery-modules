# Generate CA private key
resource "tls_private_key" "ca" {
  count     = var.enable_encryption ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = var.ssl_key_bits
}

# Generate CA certificate
resource "tls_self_signed_cert" "ca" {
  count           = var.enable_encryption ? 1 : 0
  private_key_pem = tls_private_key.ca[0].private_key_pem

  subject {
    common_name  = "${var.cluster_name} CA"
    organization = "ClickHouse Cluster"
  }

  validity_period_hours = var.ssl_cert_days * 24
  is_ca_certificate     = true

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

# Store CA materials in Secrets Manager
resource "aws_secretsmanager_secret" "ca_materials" {
  count                   = var.enable_encryption ? 1 : 0
  name_prefix             = "${var.cluster_name}-ca-"
  description             = "CA materials for ClickHouse cluster TLS"
  recovery_window_in_days = 0 # Allow immediate deletion with terraform destroy
}

resource "aws_secretsmanager_secret_version" "ca_materials" {
  count     = var.enable_encryption ? 1 : 0
  secret_id = aws_secretsmanager_secret.ca_materials[0].id
  secret_string = jsonencode({
    ca_private_key = tls_private_key.ca[0].private_key_pem
    ca_certificate = tls_self_signed_cert.ca[0].cert_pem
  })
}

# Generate keeper node private keys and certs
resource "tls_private_key" "keeper" {
  for_each  = var.enable_encryption ? local.keeper_nodes : {}
  algorithm = "RSA"
  rsa_bits  = var.ssl_key_bits
}

resource "tls_cert_request" "keeper" {
  for_each        = var.enable_encryption ? local.keeper_nodes : {}
  private_key_pem = tls_private_key.keeper[each.key].private_key_pem

  subject {
    common_name = each.value.host
  }

  dns_names = [each.value.host]
}

resource "tls_locally_signed_cert" "keeper" {
  for_each           = var.enable_encryption ? local.keeper_nodes : {}
  cert_request_pem   = tls_cert_request.keeper[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.ca[0].private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca[0].cert_pem

  validity_period_hours = var.ssl_cert_days * 24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

# Generate cluster node private keys and certs
resource "tls_private_key" "cluster" {
  for_each  = var.enable_encryption ? local.cluster_nodes : {}
  algorithm = "RSA"
  rsa_bits  = var.ssl_key_bits
}

resource "tls_cert_request" "cluster" {
  for_each        = var.enable_encryption ? local.cluster_nodes : {}
  private_key_pem = tls_private_key.cluster[each.key].private_key_pem

  subject {
    common_name = each.value.host
  }

  dns_names = compact([
    each.value.host,
    var.enable_nlb ? aws_lb.nlb[0].dns_name : ""
  ])
}

resource "tls_locally_signed_cert" "cluster" {
  for_each           = var.enable_encryption ? local.cluster_nodes : {}
  cert_request_pem   = tls_cert_request.cluster[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.ca[0].private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca[0].cert_pem

  validity_period_hours = var.ssl_cert_days * 24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

# Store node certificates in Secrets Manager
resource "aws_secretsmanager_secret" "node_certs" {
  for_each                = var.enable_encryption ? merge(local.keeper_nodes, local.cluster_nodes) : {}
  name_prefix             = "${var.cluster_name}-${each.key}-cert-"
  description             = "TLS materials for ${each.key}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "node_certs" {
  for_each = var.enable_encryption ? merge(
    # Keeper node certs
    { for k, v in local.keeper_nodes : k => {
      secret_id   = aws_secretsmanager_secret.node_certs[k].id
      private_key = tls_private_key.keeper[k].private_key_pem
      certificate = tls_locally_signed_cert.keeper[k].cert_pem
    } },
    # Cluster node certs
    { for k, v in local.cluster_nodes : k => {
      secret_id   = aws_secretsmanager_secret.node_certs[k].id
      private_key = tls_private_key.cluster[k].private_key_pem
      certificate = tls_locally_signed_cert.cluster[k].cert_pem
    } }
  ) : {}

  secret_id = each.value.secret_id
  secret_string = jsonencode({
    private_key = each.value.private_key
    certificate = each.value.certificate
  })
}

# Generate NLB cert signed by our CA
resource "tls_private_key" "nlb" {
  count     = var.enable_encryption && var.enable_nlb ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = var.ssl_key_bits
}

resource "tls_cert_request" "nlb" {
  count           = var.enable_encryption && var.enable_nlb ? 1 : 0
  private_key_pem = tls_private_key.nlb[0].private_key_pem

  subject {
    common_name = coalesce(var.cluster_domain, "clickhouse.internal")
  }

  dns_names = compact([
    coalesce(var.cluster_domain, "clickhouse.internal"),
    "*.clickhouse.internal",
    aws_lb.nlb[0].dns_name
  ])
}

resource "tls_locally_signed_cert" "nlb" {
  count              = var.enable_encryption && var.enable_nlb ? 1 : 0
  cert_request_pem   = tls_cert_request.nlb[0].cert_request_pem
  ca_private_key_pem = tls_private_key.ca[0].private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca[0].cert_pem

  validity_period_hours = var.ssl_cert_days * 24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
  ]
}

# Create ACM certificate for NLB
resource "aws_acm_certificate" "nlb" {
  count             = var.enable_encryption && var.enable_nlb ? 1 : 0
  private_key       = tls_private_key.nlb[0].private_key_pem
  certificate_body  = tls_locally_signed_cert.nlb[0].cert_pem
  certificate_chain = tls_self_signed_cert.ca[0].cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

# Grant access to the secrets via IAM
resource "aws_iam_policy" "secrets_access" {
  count       = var.enable_encryption ? 1 : 0
  name        = "${var.cluster_name}-secrets-access"
  description = "Allow access to ClickHouse secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = concat(
          [aws_secretsmanager_secret.ca_materials[0].arn],
          [aws_secretsmanager_secret.clickhouse_credentials.arn],
          [for secret in aws_secretsmanager_secret.node_certs : secret.arn]
        )
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_policy" {
  count      = var.enable_encryption ? 1 : 0
  role       = aws_iam_role.clickhouse_role.name
  policy_arn = aws_iam_policy.secrets_access[0].arn
}
