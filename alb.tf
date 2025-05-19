### ALB ###

resource "aws_lb" "alb-inpost" {
  name                       = var.alb-inpost["name"]
  internal                   = var.alb-inpost["internal"]
  load_balancer_type         = var.alb-inpost["load_balancer_type"]
  idle_timeout               = var.alb-inpost["idle_timeout"]
  security_groups            = [aws_security_group.alb-inpost.id]
  subnets                    = [aws_subnet.prod-dmz-1a.id, aws_subnet.prod-dmz-1b.id]
  enable_deletion_protection = var.alb-inpost["deletion_protection"]

  tags = {
    Name = var.alb-inpost["name"]
  }
}


### HTTPS LISTENER ###

resource "aws_lb_listener" "alb-inpost-https" {
  load_balancer_arn = aws_lb.alb-inpost.arn
  protocol          = var.alb-inpost-https-listener["protocol"]
  port              = var.alb-inpost-https-listener["port"]
  ssl_policy        = var.alb-inpost-https-listener["ssl_policy"]
  certificate_arn   = var.alb-inpost-https-listener["certificate_arn"]

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }

  tags = {
    Protocol = var.alb-inpost-https-listener["protocol"]
  }
}

resource "aws_lb_listener_rule" "alb-inpost-https-rule-100" {
  listener_arn = aws_lb_listener.alb-inpost-https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-inpost.arn
  }

  condition {
    host_header {
      values = ["app.inpost.pl"]
    }
  }
}

### HTTP LISTENER

resource "aws_lb_listener" "alb-inpost-http" {
  load_balancer_arn = aws_lb.alb-inpost.arn
  protocol          = var.alb-inpost-http-listener["protocol"]
  port              = var.alb-inpost-http-listener["port"]

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }

  tags = {
    Protocol = var.alb-inpost-http-listener["protocol"]
  }
}

resource "aws_lb_listener_rule" "alb-inpost-http-rule-100" {
  listener_arn = aws_lb_listener.alb-inpost-http.arn
  priority     = 100

  action {
    type = "redirect"

    redirect {
      port        = var.alb-inpost-http-listener["redirect_port"]
      protocol    = var.alb-inpost-http-listener["redirect_protocol"]
      status_code = var.alb-inpost-http-listener["redirect_status_code"]
    }
  }

  condition {
    host_header {
      values = ["app.inpost.pl"]
    }
  }
}

### TARGET GROUPS ###

resource "aws_lb_target_group" "tg-inpost" {
  name                 = var.tg-inpost["name"]
  protocol             = var.tg-inpost["protocol"]
  port                 = var.tg-inpost["port"]
  deregistration_delay = var.tg-inpost["deregistration_delay"]
  target_type          = var.tg-inpost["target_type"]
  vpc_id               = aws_vpc.inpost-prod.id

  health_check {
    enabled             = var.tg-inpost["health_check_enabled"]
    interval            = var.tg-inpost["health_check_interval"]
    healthy_threshold   = var.tg-inpost["health_check_healthy_threshold"]
    unhealthy_threshold = var.tg-inpost["health_check_unhealthy_threshold"]
    timeout             = var.tg-inpost["health_check_timeout"]
    path                = var.tg-inpost["health_check_path"]
    matcher             = var.tg-inpost["health_check_matcher"]
  }
}
