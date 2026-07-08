output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.main.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.main.public_dns
}

output "rds_address" {
  description = "RDS instance address"
  value       = aws_db_instance.main.address
  sensitive   = true
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}