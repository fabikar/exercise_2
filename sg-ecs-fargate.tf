resource "aws_security_group" "ecs-fargate-inpost" {
  name        = var.ecs-fargate-inpost["identifier"]
  description = var.ecs-fargate-inpost["description"]
  vpc_id      = aws_vpc.inpost-prod.id

  tags = {
    Name = var.ecs-fargate-inpost["identifier"]
  }
}

### INGRESS ###

resource "aws_security_group_rule" "ecs-fargate-inpost-in1" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "From alb-inpost to ecs-fargate-inpost "
  security_group_id        = aws_security_group.ecs-fargate-inpost.id
  source_security_group_id = aws_security_group.alb-inpost.id
}

### EGRESS ###

resource "aws_security_group_rule" "ecs-fargate-inpost-out01" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  description              = "From ecs-fargate-inpost to efs-nginx-configuration"
  security_group_id        = aws_security_group.ecs-fargate-inpost.id
  source_security_group_id = aws_security_group.efs-nginx-configuration.id
}

resource "aws_security_group_rule" "ecs-fargate-inpost-out02" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  description              = "From ecs-fargate-inpost to rds-inpost"
  security_group_id        = aws_security_group.ecs-fargate-inpost.id
  source_security_group_id = aws_security_group.rds-inpost.id
}