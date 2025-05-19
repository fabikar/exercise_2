### VPC ###

variable "vpc-prod" {
  default = {
    name                 = "inpost-prod"
    cidr                 = "10.10.0.0/16"
    enable_dns_hostnames = "true"
    enable_dns_support   = "true"
    domain_name_servers  = ["AmazonProvidedDNS"]
    ntp_servers          = ["169.254.169.123"]
  }
}


### SUBNETS ###

variable "subnet-prod-dmz-1a" {
  default = {
    name              = "Production DMZ subnet A"
    cidr              = "10.10.1.0/24"
    availability_zone = "eu-central-1a"
  }
}

variable "subnet-prod-dmz-1b" {
  default = {
    name              = "Production DMZ subnet B"
    cidr              = "10.10.2.0/24"
    availability_zone = "eu-central-1b"
  }
}

variable "subnet-prod-prv-1a" {
  default = {
    name              = "Production PRV subnet A"
    cidr              = "10.10.10.0/24"
    availability_zone = "eu-central-1a"
  }
}

variable "subnet-prod-prv-1b" {
  default = {
    name              = "Production PRV subnet B"
    cidr              = "10.10.20.0/24"
    availability_zone = "eu-central-1b"
  }
}


### RDS ###

variable "rds-inpost" {
  default = {
    identifier                   = "rds-inpost"
    description                  = "RDS MySql server"
    allocated_storage            = "20"
    storage_type                 = "gp3"
    storage_encrypted            = "true"
    engine                       = "mysql"
    engine_version               = "8.0.35"
    instance_class               = "db.t4.medium"
    multi_az                     = "true"
    backup_retention_period      = "30"
    backup_window                = "02:00-03:00"
    auto_minor_version_upgrade   = "false"
    deletion_protection          = "true"
    performance_insights_enabled = "false"
    monitoring_interval          = "0"
  }
}


### S3 ###

variable "s3-inpost" {
  default = {
    bucket = "inpost-static-assets"
  }
}


### ECR ###

variable "ecr-inpost" {
  default = {
    name = "inpost"
  }
}


### ECS ###

variable "ecs-fargate-inpost" {
  default = {
    identifier                = "ecs-fargate-inpost"
    description               = "Fargate for inpost app"
    cpu                       = 256
    memory                    = 1024
    desired_count             = 3
    cloudwatch_log_group_name = "ecs-inpost"
    cluster_name              = "ecs-cluster-inpost"
    service_name              = "ecs-service-inpost"
    task_definition_family    = "inpost"
    min_capacity              = 2
    max_capacity              = 10
    cpu_target_value          = 60

    nginx_container = {
      container_name            = "nginx"
      image                     = "public.ecr.aws/nginx/nginx:1.28.0"
      source_volume             = "nginx-configuration"
      container_path            = "/etc/nginx"
      port                      = 80
      health_check_command      = ["CMD-SHELL", "curl -f http://127.0.0.1 || exit 1"]
      health_check_interval     = 30
      health_check_timeout      = 5
      health_check_retries      = 3
      health_check_start_period = 120
    }

    app_container = {
      container_name            = "app"
      image                     = "2222222222.dkr.ecr.eu-central-1.amazonaws.com/inpost:1.0.0"
      port                      = 8080
      health_check_command      = ["CMD-SHELL", "curl -f http://127.0.0.1:8080/health_check || exit 1"]
      health_check_interval     = 30
      health_check_timeout      = 5
      health_check_retries      = 3
      health_check_start_period = 120
    }
  }
}


### EFS ###

variable "efs-nginx-configuration" {
  default = {
    name             = "efs-nginx-configuration"
    description      = "EFS filesystem for nginx-configuration on ECS Fargate"
    encrypted        = "true"
    performance_mode = "generalPurpose"
    throughput_mode  = "bursting"
    backup_policy    = "ENABLED"
  }
}


### ALB ###

variable "alb-inpost" {
  default = {
    name                = "alb-inpost"
    description         = "Application Load Balancer for ECS with inpost App"
    internal            = "false"
    load_balancer_type  = "application"
    deletion_protection = "true"
    idle_timeout        = "300"
  }
}

variable "alb-inpost-https-listener" {
  default = {
    protocol        = "HTTPS"
    port            = "443"
    ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
    certificate_arn = "arn:aws:acm:eu-central-1:2222222222:certificate/2a2a2a2a-2a2a-2a2a-2a2a-2a2a2a2a2a"
  }
}

variable "alb-inpost-http-listener" {
  default = {
    protocol             = "HTTP"
    port                 = "80"
    redirect_port        = "443"
    redirect_protocol    = "HTTPS"
    redirect_status_code = "HTTP_301"
  }
}

variable "tg-inpost" {
  default = {
    name                             = "tg-inpost"
    target_type                      = "ip"
    protocol                         = "HTTP"
    port                             = "80"
    deregistration_delay             = "20"
    health_check_enabled             = true
    health_check_interval            = 30
    health_check_healthy_threshold   = 3
    health_check_unhealthy_threshold = 3
    health_check_timeout             = 3
    health_check_path                = "/"
    health_check_matcher             = "200"
  }
}
