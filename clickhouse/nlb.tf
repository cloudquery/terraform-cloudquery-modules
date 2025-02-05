resource "aws_lb" "nlb" {
  count              = var.enable_nlb ? 1 : 0
  name               = "${var.name_prefix}clickhouse-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.nlb[0].id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
}

resource "aws_lb_listener" "clickhouse_nlb_listener" {
  count             = var.enable_nlb ? 1 : 0
  load_balancer_arn = aws_lb.nlb[0].arn
  port              = 9000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clickhouse_nlb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "clickhouse_nlb_target_group" {
  count       = var.enable_nlb ? 1 : 0
  name        = "${var.name_prefix}clickhouse-nlb-tg"
  port        = 9000
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    interval            = 30
    path                = "/ping"
    port                = 8123
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "clickhouse_nlb_target_group_attachment" {
  for_each         = var.enable_nlb ? module.clickhouse_cluster : {}
  target_group_arn = aws_lb_target_group.clickhouse_nlb_target_group[0].arn
  target_id        = module.clickhouse_cluster[each.key].id
  port             = 9000
}
