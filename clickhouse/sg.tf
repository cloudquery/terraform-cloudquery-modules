resource "aws_security_group" "nlb" {
  count       = var.enable_nlb ? 1 : 0
  name        = "${var.cluster_name}-nlb-sg"
  description = "Security group for the ClickHouse NLB"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "nlb_ingress" {
  count             = var.enable_nlb ? 1 : 0
  description       = "Allow external traffic to the ClickHouse cluster"
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  security_group_id = aws_security_group.nlb[0].id
  # Optional: Replace with specific CIDR blocks if possible
  cidr_blocks = var.allowed_cidr_blocks
}

resource "aws_security_group_rule" "nlb_clickhouse_egress" {
  count                    = var.enable_nlb ? 1 : 0
  description              = "Allow NLB to talk to the ClickHouse cluster"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nlb[0].id
  source_security_group_id = aws_security_group.clickhouse_cluster.id
}

resource "aws_security_group" "clickhouse_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for the ClickHouse cluster"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "cluster_allow_all_outbound" {
  description       = "Allow all outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.clickhouse_cluster.id
}

resource "aws_security_group_rule" "clickhouse_healthcheck" {
  count                    = var.enable_nlb ? 1 : 0
  description              = "Allow healthcheck from the NLB"
  type                     = "ingress"
  from_port                = 8123
  to_port                  = 8123
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clickhouse_cluster.id
  source_security_group_id = aws_security_group.nlb[0].id
}

resource "aws_security_group_rule" "clickhouse_nlb_ingress" {
  count                    = var.enable_nlb ? 1 : 0
  description              = "Allow NLB to communicate with the ClickHouse cluster"
  type                     = "ingress"
  from_port                = 9000
  to_port                  = 9000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clickhouse_cluster.id
  source_security_group_id = aws_security_group.nlb[0].id
}

resource "aws_security_group_rule" "clickhouse_ingress" {
  description       = "Allow ClickHouse cluster to communicate with the other clickhouse nodes"
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "-1"
  security_group_id = aws_security_group.clickhouse_cluster.id
  self              = true
}

resource "aws_security_group_rule" "clickhouse_egress" {
  description       = "Allow ClickHouse cluster to communicate with the other clikchouse nodes"
  type              = "egress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "-1"
  security_group_id = aws_security_group.clickhouse_cluster.id
  self              = true
}

resource "aws_security_group" "clickhouse_keeper" {
  name        = "${var.cluster_name}-keeper-sg"
  description = "Security group for the ClickHouse keepers"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "keeper_cluster_to_keeper" {
  description              = "Allow ClickHouse cluster to communicate with the keepers"
  type                     = "ingress"
  from_port                = 9181
  to_port                  = 9181
  protocol                 = "-1"
  source_security_group_id = aws_security_group.clickhouse_cluster.id
  security_group_id        = aws_security_group.clickhouse_keeper.id
}

resource "aws_security_group_rule" "cluster_cluster_to_keeper" {
  description              = "Allow ClickHouse cluster to communicate with the keepers"
  type                     = "egress"
  from_port                = 9181
  to_port                  = 9181
  protocol                 = "-1"
  source_security_group_id = aws_security_group.clickhouse_keeper.id
  security_group_id        = aws_security_group.clickhouse_cluster.id
}

resource "aws_security_group_rule" "keeper_ingress" {
  description              = "Allow ClickHouse keepers to communicate with each other (Raft protocol)"
  type                     = "ingress"
  from_port                = 9234
  to_port                  = 9234
  protocol                 = "-1"
  source_security_group_id = aws_security_group.clickhouse_keeper.id
  security_group_id        = aws_security_group.clickhouse_keeper.id
}

resource "aws_security_group_rule" "keeper_egress" {
  description              = "Allow ClickHouse keepers to communicate with each other (Raft protocol)"
  type                     = "egress"
  from_port                = 9234
  to_port                  = 9234
  protocol                 = "-1"
  source_security_group_id = aws_security_group.clickhouse_keeper.id
  security_group_id        = aws_security_group.clickhouse_keeper.id
}

resource "aws_security_group_rule" "keeper_allow_all_outbound" {
  description       = "Allow all outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.clickhouse_keeper.id
}
