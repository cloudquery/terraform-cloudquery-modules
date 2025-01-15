resource "aws_security_group" "clickhouse_cluster" {
  name        = "clickhouse_cluster-sg"
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

resource "aws_security_group_rule" "clickhouse_ingress" {
  description       = "Allow ClickHouse cluster to communicate with the other clikchouse nodes"
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.clickhouse_cluster.id
}

resource "aws_security_group_rule" "clickhouse_egress" {
  description       = "Allow ClickHouse cluster to communicate with the other clikchouse nodes"
  type              = "egress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.clickhouse_cluster.id
}

resource "aws_security_group" "clickhouse_keeper" {
  name        = "clickhouse-keeper-sg"
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
