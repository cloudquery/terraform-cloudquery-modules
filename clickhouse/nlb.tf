resource "aws_lb" "nlb" {
  count              = var.enable_nlb ? 1 : 0
  name               = "${var.cluster_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.nlb[0].id]
  subnets            = var.nlb_type == "internal" ? module.vpc.private_subnets : module.vpc.public_subnets

  enable_deletion_protection = false
}

resource "aws_lb_listener" "clickhouse_nlb_listener" {
  count             = var.enable_nlb ? 1 : 0
  load_balancer_arn = aws_lb.nlb[0].arn
  port              = var.enable_nlb_tls || var.enable_encryption ? var.tcp_port_secure : var.tcp_port
  protocol          = var.enable_nlb_tls ? "TLS" : "TCP"

  # Use provided certificate ARN or generated certificate
  certificate_arn = var.enable_nlb_tls ? (
    var.use_generated_cert ? aws_acm_certificate.nlb[0].arn : var.tls_certificate_arn
  ) : null

  ssl_policy = var.enable_nlb_tls ? "ELBSecurityPolicy-TLS13-1-2-2021-06" : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clickhouse_nlb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "clickhouse_nlb_target_group" {
  count       = var.enable_nlb ? 1 : 0
  name        = "${var.cluster_name}-nlb-tg"
  port        = var.enable_nlb_tls ? var.tcp_port_secure : var.tcp_port
  protocol    = var.enable_encryption ? "TLS" : "TCP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    interval            = 30
    path                = "/ping"
    port                = var.enable_encryption ? var.https_port : var.http_port
    protocol            = var.enable_encryption ? "HTTPS" : "HTTP"
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
  port             = var.enable_encryption ? var.tcp_port_secure : var.tcp_port
}
