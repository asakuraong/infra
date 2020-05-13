resource "aws_alb" "main" {
  name            = "${var.name}-load-balancer"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "web" {
  name        = "${var.name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "web" {
  load_balancer_arn = aws_alb.main.id
  port              = var.web_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.web.id
    type             = "forward"
  }
}
