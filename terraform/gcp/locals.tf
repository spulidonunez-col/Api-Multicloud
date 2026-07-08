locals {
  # Configuración de la aplicación
  app_name        = "gcp-app-conf"
  environment     = "production"
  
  # Cloud Run
  cloud_run_location = "us-central1"
  cloud_run_memory   = "512Mi"
  cloud_run_cpu      = "1"
  cloud_run_concurrency = 80
  
  # Cloud SQL
  db_tier      = "db-f1-micro"
  db_disk_size = 10
  db_version   = "POSTGRES_15"
  
  # Networking
  vpc_network = "default"
  
  # Artifact Registry
  registry_location = "us-central1"
  registry_name     = "ar-gcp-app"
}