variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "aws-demo-api"
}