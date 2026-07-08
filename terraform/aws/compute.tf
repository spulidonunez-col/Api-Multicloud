# 1. Security Group para la API (ECS Fargate)
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

# 2. ECR Repository
resource "aws_ecr_repository" "main" {
  name = local.repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = local.repo_name
  }
}