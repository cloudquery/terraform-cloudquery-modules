resource "random_password" "default_user" {
  length           = 16
  special          = true
  override_special = "-_~"
}

resource "random_password" "admin_user" {
  length           = 16
  special          = true
  override_special = "-_~"
}

# Store passwords in Secrets Manager for retrieval
resource "aws_secretsmanager_secret" "clickhouse_credentials" {
  name_prefix = "${var.cluster_name}-credentials-"
  description = "ClickHouse user credentials"
}

resource "aws_secretsmanager_secret_version" "clickhouse_credentials" {
  secret_id = aws_secretsmanager_secret.clickhouse_credentials.id
  secret_string = jsonencode({
    default_user_password = random_password.default_user.result
    admin_user_password   = random_password.admin_user.result
  })
}
