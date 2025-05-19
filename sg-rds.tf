resource "aws_security_group" "rds-inpost" {
  name        = var.rds-inpost["identifier"]
  description = var.rds-inpost["description"]
  vpc_id      = aws_vpc.inpost-prod.id

  tags = {
    Name = var.rds-inpost["identifier"]
  }
}

### INGRESS ###

resource "aws_security_group_rule" "rds-inpost-in01" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  description              = "From ecs-fargate-inpost to rds-inpost"
  security_group_id        = aws_security_group.rds-inpost.id
  source_security_group_id = aws_security_group.ecs-fargate-inpost.id
}
