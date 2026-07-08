variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "Nombre base de la aplicación"
  type        = string
  default     = "aws-mcapp"
}

variable "db_password" {
  description = "Contraseña para RDS"
  type        = string
  sensitive   = true
}