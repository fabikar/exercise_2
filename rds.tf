resource "aws_db_instance" "inpost" {
  identifier                      = var.rds-inpost["identifier"]
  allocated_storage               = var.rds-inpost["allocated_storage"]
  storage_type                    = var.rds-inpost["storage_type"]
  storage_encrypted               = var.rds-inpost["storage_encrypted"]
  engine                          = var.rds-inpost["engine"]
  engine_version                  = var.rds-inpost["engine_version"]
  instance_class                  = var.rds-inpost["instance_class"]
  username                        = local.rds-inpost-creds.user
  password                        = local.rds-inpost-creds.password
  vpc_security_group_ids          = [aws_security_group.rds-inpost.id]
  db_subnet_group_name            = aws_db_subnet_group.rds-inpost.id
  multi_az                        = var.rds-inpost["multi_az"]
  backup_retention_period         = var.rds-inpost["backup_retention_period"]
  backup_window                   = var.rds-inpost["backup_window"]
  parameter_group_name            = aws_db_parameter_group.mysql80-inpost.name
  auto_minor_version_upgrade      = var.rds-inpost["auto_minor_version_upgrade"]
  deletion_protection             = var.rds-inpost["deletion_protection"]
  performance_insights_enabled    = var.rds-inpost["performance_insights_enabled"]
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]
  monitoring_interval             = var.rds-inpost["monitoring_interval"]

  tags = {
    Name = var.rds-inpost["identifier"]
  }
}

resource "aws_db_subnet_group" "rds-inpost" {
  name       = var.rds-inpost["identifier"]
  subnet_ids = [aws_subnet.prod-prv-1a.id, aws_subnet.prod-prv-1b.id]

  tags = {
    Name = var.rds-inpost["identifier"]
  }
}

resource "aws_db_parameter_group" "mysql80-inpost" {
  name   = "mysql80-inpost"
  family = "mysql8.0"
}

data "aws_secretsmanager_secret_version" "rds-inpost" {
  secret_id = "rds-inpost"
}

locals {
  rds-inpost-creds = jsondecode(
    data.aws_secretsmanager_secret_version.rds-inpost.secret_string
  )
}