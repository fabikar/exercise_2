resource "aws_cloudwatch_log_group" "ecs-inpost" {
  name = var.ecs-fargate-inpost["cloudwatch_log_group_name"]
}

resource "aws_ecs_cluster" "ecs-inpost" {
  name = var.ecs-fargate-inpost["cluster_name"]
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs-inpost.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs-inpost" {
  cluster_name       = aws_ecs_cluster.ecs-inpost.name
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "ecs-inpost" {
  family                   = var.ecs-fargate-inpost["task_definition_family"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs-fargate-inpost["cpu"]
  memory                   = var.ecs-fargate-inpost["memory"]
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_service_role.arn
  task_role_arn            = aws_iam_role.ecs_service_role.arn

  container_definitions = jsonencode([
    {
      name      = var.ecs-fargate-inpost["nginx_container"]["container_name"]
      image     = var.ecs-fargate-inpost["nginx_container"]["image"]
      essential = true

      mountPoints = [
        {
          sourceVolume  = var.ecs-fargate-inpost["nginx_container"]["source_volume"]
          containerPath = var.ecs-fargate-inpost["nginx_container"]["container_path"]
        }
      ]

      portMappings = [
        {
          containerPort = var.ecs-fargate-inpost["nginx_container"]["port"]
        }
      ]

      healthCheck = {
        command     = var.ecs-fargate-inpost["nginx_container"]["health_check_command"]
        interval    = var.ecs-fargate-inpost["nginx_container"]["health_check_interval"]
        timeout     = var.ecs-fargate-inpost["nginx_container"]["health_check_timeout"]
        retries     = var.ecs-fargate-inpost["nginx_container"]["health_check_retries"]
        startPeriod = var.ecs-fargate-inpost["nginx_container"]["health_check_start_period"]
      }

      log_configuration = {
        log_driver = "awslogs"

        options = {
          awslogs-group         = var.ecs-fargate-inpost["cloudwatch_log_group_name"]
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.ecs-fargate-inpost["nginx_container"]["container_name"]
        }
      }
    },
    {
      name      = var.ecs-fargate-inpost["app_container"]["container_name"]
      image     = var.ecs-fargate-inpost["app_container"]["image"]
      essential = true

      portMappings = [
        {
          containerPort = var.ecs-fargate-inpost["app_container"]["port"]
        }
      ]

      healthCheck = {
        command     = var.ecs-fargate-inpost["app_container"]["health_check_command"]
        interval    = var.ecs-fargate-inpost["app_container"]["health_check_interval"]
        timeout     = var.ecs-fargate-inpost["app_container"]["health_check_timeout"]
        retries     = var.ecs-fargate-inpost["app_container"]["health_check_retries"]
        startPeriod = var.ecs-fargate-inpost["app_container"]["health_check_start_period"]
      }

      log_configuration = {
        log_driver = "awslogs"

        options = {
          awslogs-group         = var.ecs-fargate-inpost["cloudwatch_log_group_name"]
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.ecs-fargate-inpost["app_container"]["container_name"]
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  volume {
    name = var.ecs-fargate-inpost["nginx_container"]["source_volume"]

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.efs-nginx-configuration.id
      root_directory     = var.ecs-fargate-inpost["nginx_container"]["container_path"]
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_ecs_service" "ecs-inpost" {
  name                   = var.ecs-fargate-inpost["service_name"]
  cluster                = aws_ecs_cluster.ecs-inpost.id
  task_definition        = aws_ecs_task_definition.ecs-inpost.arn
  desired_count          = var.ecs-fargate-inpost["desired_count"]
  enable_execute_command = true

  network_configuration {
    subnets          = [aws_subnet.prod-prv-1a.id, aws_subnet.prod-prv-1b.id]
    security_groups  = [aws_security_group.ecs-fargate-inpost.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg-inpost.arn
    container_name   = var.ecs-fargate-inpost["nginx_container"]["container_name"]
    container_port   = var.ecs-fargate-inpost["nginx_container"]["port"]
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      desired_count
    ]
  }
}

resource "aws_appautoscaling_target" "ecs-inpost" {
  min_capacity       = var.ecs-fargate-inpost["min_capacity"]
  max_capacity       = var.ecs-fargate-inpost["max_capacity"]
  resource_id        = "service/${var.ecs-fargate-inpost["cluster_name"]}/${var.ecs-fargate-inpost["service_name"]}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs-inpost-cpu-policy" {
  name               = "cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs-inpost.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs-inpost.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs-inpost.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = var.ecs-fargate-inpost["cpu_target_value"]
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs_service_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ECSmanagePolicy" {
  name = "ECSmanagePolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ecs:*",
            "Resource": [
              "arn:aws:ecs:eu-central-1:2222222222:*/ecs-inpost/*",
              "arn:aws:ecs:eu-central-1:2222222222:*/ecs-inpost"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "ecr:*",
            "Resource": "arn:aws:ecr:eu-central-1:2222222222:repository/inpost"
        },
        {
            "Action": "ecr:GetAuthorizationToken",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
              "elasticloadbalancing:Create*",
              "elasticloadbalancing:Deregister*",
              "elasticloadbalancing:Describe*",
              "elasticloadbalancing:Modify*",
              "elasticloadbalancing:Register*",
              "elasticloadbalancing:Create*"
            ],
            "Resource": [
              "arn:aws:elasticloadbalancing:eu-central-1:2222222222:loadbalancer/*/ecs-*"
            ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ],
          "Resource": "arn:aws:logs:eu-central-1:2222222222:log-group:ecs-inpost:*" 
        },
        {
          "Effect": "Allow",
          "Action": [
              "ssmmessages:CreateControlChannel",
              "ssmmessages:CreateDataChannel",
              "ssmmessages:OpenControlChannel",
              "ssmmessages:OpenDataChannel"
          ],
          "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment_01" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = aws_iam_policy.ECSmanagePolicy.arn
}
