resource "aws_efs_file_system" "efs-nginx-configuration" {
  creation_token   = var.efs-nginx-configuration["name"]
  encrypted        = var.efs-nginx-configuration["encrypted"]
  performance_mode = var.efs-nginx-configuration["performance_mode"]
  throughput_mode  = var.efs-nginx-configuration["throughput_mode"]

  tags = {
    Name = var.efs-nginx-configuration["name"]
  }
}

resource "aws_efs_backup_policy" "efs-nginx-configuration" {
  file_system_id = aws_efs_file_system.efs-nginx-configuration.id

  backup_policy {
    status = var.efs-nginx-configuration["backup_policy"]
  }
}

resource "aws_efs_mount_target" "efs-nginx-configuration-1a" {
  file_system_id  = aws_efs_file_system.efs-nginx-configuration.id
  subnet_id       = aws_subnet.prod-prv-1a.id
  security_groups = [aws_security_group.efs-nginx-configuration.id]
}

resource "aws_efs_mount_target" "efs-nginx-configuration-1b" {
  file_system_id  = aws_efs_file_system.efs-nginx-configuration.id
  subnet_id       = aws_subnet.prod-prv-1b.id
  security_groups = [aws_security_group.efs-nginx-configuration.id]
}