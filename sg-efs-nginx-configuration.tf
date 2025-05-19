resource "aws_security_group" "efs-nginx-configuration" {
  name        = var.efs-nginx-configuration["name"]
  description = var.efs-nginx-configuration["description"]
  vpc_id      = aws_vpc.inpost-prod.id

  tags = {
    Name = var.efs-nginx-configuration["name"]
  }
}

### INGRESS ###

resource "aws_security_group_rule" "efs-nginx-configuration-in01" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  description              = "From ecs-fargate-inpost to efs-nginx-configuration"
  security_group_id        = aws_security_group.efs-nginx-configuration.id
  source_security_group_id = aws_security_group.ecs-fargate-inpost.id
}
