# ==================== VPC ====================
resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${local.app_name}-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_a_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  
  tags = {
    Name = "${local.app_name}-subnet-a"
  }
}

# Agregar SEGUNDA SUBNET
resource "aws_subnet" "secondary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_b_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}b"
  
  tags = {
    Name = "${local.app_name}-subnet-b"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${local.app_name}-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${local.app_name}-rt"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# ==================== SECURITY GROUPS ====================
resource "aws_security_group" "api" {
  name        = "${local.app_name}-api-sg"
  description = "Allow HTTP/HTTPS traffic"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_security_group" "db" {
  name        = "${local.app_name}-db-sg"
  description = "Allow PostgreSQL from API"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.api.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${local.app_name}-db-sg"
  }
}

# ==================== RDS ====================
resource "aws_db_subnet_group" "main" {
  name       = "${local.app_name}-db-subnet"
  subnet_ids = [aws_subnet.main.id, aws_subnet.secondary.id]
  
  tags = {
    Name = "${local.app_name}-db-subnet"
  }
}

resource "aws_db_instance" "main" {
  identifier        = "${local.app_name}-db"
  engine            = local.db_engine
  engine_version    = local.db_engine_version
  instance_class    = local.db_tier
  allocated_storage = local.db_disk_size
  storage_encrypted = true
  
  db_name  = "DemoApi"
  username = "psqluser"
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  publicly_accessible = true
  skip_final_snapshot = true
  
  tags = {
    Name = "${local.app_name}-db"
  }
}

# ==================== ECR ====================
resource "aws_ecr_repository" "main" {
  name = local.ecr_repo_name
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    Name = "${local.app_name}-ecr"
  }
}

# ==================== EC2 ====================
resource "aws_instance" "main" {
  ami                    = local.ami_id
  instance_type          = local.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.api.id]
  
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io awscli
    systemctl start docker
    systemctl enable docker
    
    # Autenticar en ECR
    aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}
    
    # Crear directorio para app
    mkdir -p /app
    
    # Variables de entorno para la app
    echo "DATABASE_URL=postgresql://psqluser:${var.db_password}@${aws_db_instance.main.address}:5432/DemoApi" > /app/.env
    echo "ENVIRONMENT=production" >> /app/.env
    
    # Pull y ejecutar contenedor
    docker pull ${aws_ecr_repository.main.repository_url}:latest
    docker run -d --name aws-demo-api -p 8000:8000 --env-file /app/.env ${aws_ecr_repository.main.repository_url}:latest
  EOF
  
  tags = {
    Name = "${local.app_name}-ec2"
  }
  
  depends_on = [
    aws_db_instance.main,
    aws_ecr_repository.main
  ]
}