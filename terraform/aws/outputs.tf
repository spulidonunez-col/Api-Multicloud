output "rds_endpoint" {
  description = "Endpoint de RDS"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "Puerto de RDS"
  value       = aws_db_instance.main.port
}

output "secret_arn" {
  description = "ARN del secret en Secrets Manager"
  value       = aws_secretsmanager_secret.db_password.arn
  sensitive   = true
}