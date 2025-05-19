resource "aws_security_group" "alb-inpost" {
  name        = var.alb-inpost["name"]
  description = var.alb-inpost["description"]
  vpc_id      = aws_vpc.inpost-prod.id

  tags = {
    Name = var.alb-inpost["name"]
  }
}

### INGRESS ###

resource "aws_security_group_rule" "alb-inpost-in01" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  description       = "From Internet to alb-inpost https"
  security_group_id = aws_security_group.alb-inpost.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb-inpost-in02" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  description       = "From Internet to alb-inpost http"
  security_group_id = aws_security_group.alb-inpost.id
  cidr_blocks       = ["0.0.0.0/0"]
}

### EGRESS ###

resource "aws_security_group_rule" "alb-inpost-out01" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "From alb-inpost to ecs-fargate-inpost"
  security_group_id        = aws_security_group.alb-inpost.id
  source_security_group_id = aws_security_group.ecs-fargate-inpost.id
}