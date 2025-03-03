# Base security groups (without any rules)
resource "aws_security_group" "nlb" {
  count       = var.enable_nlb ? 1 : 0
  name        = "${var.cluster_name}-nlb-sg"
  description = "Security group for the ClickHouse NLB"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

resource "aws_security_group" "clickhouse_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for the ClickHouse cluster"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

resource "aws_security_group" "clickhouse_keeper" {
  name        = "${var.cluster_name}-keeper-sg"
  description = "Security group for the ClickHouse keepers"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

# NLB Rules
resource "aws_security_group_rule" "nlb_inbound" {
  count             = var.enable_nlb ? 1 : 0
  security_group_id = aws_security_group.nlb[0].id
  type              = "ingress"
  from_port         = var.enable_encryption ? var.tcp_port_secure : var.tcp_port
  to_port           = var.enable_encryption ? var.tcp_port_secure : var.tcp_port
  protocol          = "tcp"
  cidr_blocks       = var.nlb_type == "external" ? var.allowed_cidr_blocks : [local.vpc_cidr]
  description       = "Allow inbound traffic to NLB"
}

resource "aws_security_group_rule" "nlb_http_inbound" {
  count             = var.enable_nlb ? 1 : 0
  security_group_id = aws_security_group.nlb[0].id
  type              = "ingress"
  from_port         = var.enable_encryption ? var.https_port : var.http_port
  to_port           = var.enable_encryption ? var.https_port : var.http_port
  protocol          = "tcp"
  cidr_blocks       = var.nlb_type == "external" ? ["0.0.0.0/0"] : [local.vpc_cidr]
  description       = "Allow inbound HTTP traffic to ClickHouse NLB"
}

resource "aws_security_group_rule" "nlb_to_clickhouse" {
  count                    = var.enable_nlb ? 1 : 0
  security_group_id        = aws_security_group.nlb[0].id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.clickhouse_cluster.id
  description              = "Allow NLB to talk to ClickHouse cluster"
}

# ClickHouse Cluster Rules
resource "aws_security_group_rule" "clickhouse_cluster_ingress" {
  security_group_id = aws_security_group.clickhouse_cluster.id
  type              = "ingress"
  from_port         = var.enable_encryption ? var.tcp_port_secure : var.tcp_port
  to_port           = var.enable_encryption ? var.tcp_port_secure : var.tcp_port
  protocol          = "tcp"
  self              = true
  description       = "Allow internal cluster communication"
}

resource "aws_security_group_rule" "clickhouse_from_nlb" {
  count                    = var.enable_nlb ? 1 : 0
  security_group_id        = aws_security_group.clickhouse_cluster.id
  type                     = "ingress"
  from_port                = var.enable_encryption ? var.tcp_port_secure : var.tcp_port
  to_port                  = var.enable_encryption ? var.tcp_port_secure : var.tcp_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nlb[0].id
  description              = "Allow traffic from NLB"
}

resource "aws_security_group_rule" "clickhouse_health_check" {
  count                    = var.enable_nlb ? 1 : 0
  security_group_id        = aws_security_group.clickhouse_cluster.id
  type                     = "ingress"
  from_port                = var.enable_encryption ? var.https_port : var.http_port
  to_port                  = var.enable_encryption ? var.https_port : var.http_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nlb[0].id
  description              = "Allow health checks from NLB"
}

resource "aws_security_group_rule" "clickhouse_prometheus" {
  security_group_id = aws_security_group.clickhouse_cluster.id
  type              = "ingress"
  from_port         = var.prometheus_port
  to_port           = var.prometheus_port
  protocol          = "tcp"
  self              = true
  description       = "Allow Prometheus metrics access"
}

resource "aws_security_group_rule" "clickhouse_interserver" {
  security_group_id = aws_security_group.clickhouse_cluster.id
  type              = "ingress"
  from_port         = var.enable_encryption ? var.interserver_https_port : var.interserver_http_port
  to_port           = var.enable_encryption ? var.interserver_https_port : var.interserver_http_port
  protocol          = "tcp"
  self              = true
  description       = "Allow inter-server communication"
}

resource "aws_security_group_rule" "clickhouse_keeper_access" {
  security_group_id        = aws_security_group.clickhouse_cluster.id
  type                     = "egress"
  from_port                = var.enable_encryption ? var.keeper_port_secure : var.keeper_port
  to_port                  = var.enable_encryption ? var.keeper_port_secure : var.keeper_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.clickhouse_keeper.id
  description              = "Allow access to keepers"
}

# Global outbound rule - only need one
resource "aws_security_group_rule" "clickhouse_outbound" {
  security_group_id = aws_security_group.clickhouse_cluster.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# Keeper Rules
resource "aws_security_group_rule" "keeper_cluster_access" {
  security_group_id        = aws_security_group.clickhouse_keeper.id
  type                     = "ingress"
  from_port                = var.enable_encryption ? var.keeper_port_secure : var.keeper_port
  to_port                  = var.enable_encryption ? var.keeper_port_secure : var.keeper_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.clickhouse_cluster.id
  description              = "Allow access from cluster nodes"
}

resource "aws_security_group_rule" "keeper_raft" {
  security_group_id = aws_security_group.clickhouse_keeper.id
  type              = "ingress"
  from_port         = var.keeper_raft_port
  to_port           = var.keeper_raft_port
  protocol          = "tcp"
  self              = true
  description       = "Allow Raft protocol communication"
}

resource "aws_security_group_rule" "keeper_outbound" {
  security_group_id = aws_security_group.clickhouse_keeper.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

locals {
  # Compute the actual CIDR blocks for SSH access
  ssh_cidr_blocks = var.ssh_access.enabled ? distinct(concat(
    var.ssh_access.cidr_blocks,
    var.ssh_access.include_vpc_cidr ? [local.vpc_cidr] : []
  )) : []
}

resource "aws_security_group_rule" "cluster_ssh" {
  count             = var.ssh_access.enabled ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = local.ssh_cidr_blocks
  security_group_id = aws_security_group.clickhouse_cluster.id
  description       = "Allow SSH access"
}

resource "aws_security_group_rule" "keeper_ssh" {
  count             = var.ssh_access.enabled ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = local.ssh_cidr_blocks
  security_group_id = aws_security_group.clickhouse_keeper.id
  description       = "Allow SSH access"
}
