resource "aws_security_group" "nlb" {
  count       = var.enable_nlb ? 1 : 0
  name        = "clickhouse-nlb-sg"
  description = "Security group for the ClickHouse NLB"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "nlb_ingress" {
  count             = var.enable_nlb ? 1 : 0
  description       = "Allow inbound traffic to NLB"
  type              = "ingress"
  from_port         = var.enable_encryption ? 9440 : 9000
  to_port           = var.enable_encryption ? 9440 : 9000
  protocol          = "tcp"
  security_group_id = aws_security_group.nlb[0].id
  cidr_blocks       = var.nlb_type == "external" ? ["0.0.0.0/0"] : [local.vpc_cidr]
}

resource "aws_security_group_rule" "clickhouse_secure_ingress" {
  count                    = var.enable_encryption ? 1 : 0
  description              = "Allow encrypted ClickHouse traffic"
  type                     = "ingress"
  from_port                = var.tcp_port_secure
  to_port                  = var.tcp_port_secure
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clickhouse_cluster.id
  source_security_group_id = aws_security_group.clickhouse_cluster.id
}

resource "aws_security_group_rule" "nlb_secure_ingress" {
  count                    = var.enable_nlb && var.enable_encryption ? 1 : 0
  description              = "Allow encrypted traffic from NLB"
  type                     = "ingress"
  from_port                = 9440
  to_port                  = 9440
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clickhouse_cluster.id
  source_security_group_id = aws_security_group.nlb[0].id
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
  name        = "clickhouse_cluster-sg"
  description = "Security group for the ClickHouse cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Prometheus metrics"
    from_port   = var.prometheus_port
    to_port     = var.prometheus_port
    protocol    = "tcp"
    self        = true
  }

  dynamic "ingress" {
    for_each = var.enable_encryption ? [1] : []
    content {
      from_port = var.https_port
      to_port   = var.https_port
      protocol  = "tcp"
      self      = true
    }
  }

  dynamic "ingress" {
    for_each = var.enable_encryption ? [1] : []
    content {
      from_port = var.tcp_port_secure
      to_port   = var.tcp_port_secure
      protocol  = "tcp"
      self      = true
    }
  }

  dynamic "ingress" {
    for_each = var.enable_encryption ? [1] : []
    content {
      from_port = var.interserver_https_port
      to_port   = var.interserver_https_port
      protocol  = "tcp"
      self      = true
    }
  }

  dynamic "ingress" {
    for_each = var.enable_encryption ? [] : [1]
    content {
      from_port = var.http_port
      to_port   = var.http_port
      protocol  = "tcp"
      self      = true
    }
  }

  dynamic "ingress" {
    for_each = var.enable_encryption ? [] : [1]
    content {
      from_port = var.tcp_port
      to_port   = var.tcp_port
      protocol  = "tcp"
      self      = true
    }
  }

  dynamic "ingress" {
    for_each = var.enable_encryption ? [] : [1]
    content {
      from_port = var.interserver_http_port
      to_port   = var.interserver_http_port
      protocol  = "tcp"
      self      = true
    }
  }
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
  description       = "Allow ClickHouse cluster to communicate with other clickhouse nodes"
  type              = "ingress"
  from_port         = var.tcp_port
  to_port           = var.tcp_port
  protocol          = "tcp"
  security_group_id = aws_security_group.clickhouse_cluster.id
  self              = true
}

resource "aws_security_group_rule" "clickhouse_egress" {
  description       = "Allow ClickHouse cluster to communicate with other clickhouse nodes"
  type              = "egress"
  from_port         = var.tcp_port
  to_port           = var.tcp_port
  protocol          = "tcp"
  security_group_id = aws_security_group.clickhouse_cluster.id
  self              = true
}

resource "aws_security_group" "clickhouse_keeper" {
  name        = "clickhouse-keeper-sg"
  description = "Security group for the ClickHouse keepers"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Keeper Raft protocol"
    from_port   = var.keeper_raft_port
    to_port     = var.keeper_raft_port
    protocol    = "tcp"
    self        = true
  }

  dynamic "ingress" {
    for_each = var.enable_encryption ? [1] : []
    content {
      from_port = var.keeper_port_secure
      to_port   = var.keeper_port_secure
      protocol  = "tcp"
      self      = true
    }
  }

  dynamic "ingress" {
    for_each = var.enable_encryption ? [] : [1]
    content {
      from_port = var.keeper_port
      to_port   = var.keeper_port
      protocol  = "tcp"
      self      = true
    }
  }
}

resource "aws_security_group_rule" "keeper_cluster_to_keeper" {
  description              = "Allow ClickHouse cluster to communicate with keepers"
  type                     = "ingress"
  from_port                = var.keeper_port
  to_port                  = var.keeper_port
  protocol                 = "tcp"
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
