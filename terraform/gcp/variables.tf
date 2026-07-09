variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "gcp-mcapp"
}

variable "service_account_email" {
  description = "Email de la Service Account de Terraform"
  type        = string
  default     = "sa-tf-user@gcp-msapp.iam.gserviceaccount.com"
}