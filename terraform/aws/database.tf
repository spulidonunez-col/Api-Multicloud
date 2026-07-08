# 1. Grupo de subredes (2 AZs)
resource "aws_db_subnet_group" "main" {
  name       = "${local.app_name}-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "${local.app_name}-db-subnet-group"
  }
}

# 2. Security Group para RDS
resource "aws_security_group" "db" {
  name        = "${local.app_name}-db-sg"
  description = "Allow PostgreSQL traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.api_sg.id]  # Se creará en compute.tf
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

# 3. RDS Instance
resource "aws_db_instance" "main" {
  identifier = local.db_instance_name

  engine         = local.db_engine
  engine_version = local.db_engine_version
  instance_class = local.db_tier
  allocated_storage = local.db_disk_size
  storage_encrypted = true

  db_name  = local.db_name
  username = local.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  # Aislamiento
  publicly_accessible = false

  # Backup
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot = true

  tags = {
    Name = local.db_instance_name
  }

  depends_on = [aws_db_subnet_group.main]
}