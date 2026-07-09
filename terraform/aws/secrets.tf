# 1. Crear el secret
resource "aws_secretsmanager_secret" "db_password" {
  name = "${local.app_name}-db-password"
  description = "Contraseña para RDS"
  recovery_window_in_days = 0

  tags = {
    Name = "${local.app_name}-db-password"   
  }
}

# 2. Guardar la contraseña en el secret (primera versión)
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

# 3. Política para permitir a ECS leer el secret
resource "aws_secretsmanager_secret_policy" "allow_ecs" {
  secret_arn = aws_secretsmanager_secret.db_password.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Principal = { Service = "ecs.amazonaws.com" }
        Action   = "secretsmanager:GetSecretValue"
        Resource = aws_secretsmanager_secret.db_password.arn
      }
    ]
  })
}