#  Security Group para la API (ECS Fargate)
resource "aws_security_group" "api_sg" {
  name        = "${local.app_name}-api-sg"
  description = "Allow HTTP/HTTPS traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Solo para pruebas
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.app_name}-api-sg"
  }
}

# ECR Repository
resource "aws_ecr_repository" "main" {
  name = local.repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = local.repo_name
  }
}

##
# ECS Cluster (Fargate)
resource "aws_ecs_cluster" "main" {
  name = "${local.app_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${local.app_name}-cluster"
  }
}
##
# 3a. IAM Role para ejecución de ECS
resource "aws_iam_role" "ecs_execution" {
  name = "${local.app_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.app_name}-ecs-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 3b. IAM Role para la tarea (permisos para Secrets Manager)
resource "aws_iam_role" "ecs_task" {
  name = "${local.app_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.app_name}-ecs-task-role"
  }
}

resource "aws_iam_role_policy" "secrets_access" {
  name = "${local.app_name}-secrets-access"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.db_password.arn
      }
    ]
  })
}
##
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${local.app_name}"
  retention_in_days = 7

  tags = {
    Name = "/ecs/${local.app_name}"
  }
}
##
# Task Definition (Fargate)
resource "aws_ecs_task_definition" "main" {
  family                   = local.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.cpu
  memory                   = local.memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = local.container_name
      image = "${aws_ecr_repository.main.repository_url}:latest"  # Placeholder
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ENVIRONMENT"
          value = "production"
        },
        {
          name  = "DATABASE_HOST"
          value = aws_db_instance.main.address
        },
        {
          name  = "DATABASE_NAME"
          value = local.db_name
        },
        {
          name  = "DATABASE_USER"
          value = local.db_user
        }
      ]
      secrets = [
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = aws_secretsmanager_secret.db_password.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${local.app_name}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = local.task_family
  }

  depends_on = [aws_ecr_repository.main]
}

# ECS Service (Fargate)
resource "aws_ecs_service" "main" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.api_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = local.container_name
    container_port   = 8000
  }

  depends_on = [
    aws_lb_target_group.main,
    aws_ecs_task_definition.main
  ]

  tags = {
    Name = local.service_name
  }
}