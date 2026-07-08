locals {
  # Nombre base de la aplicación
  app_name = var.service_name

  # ===== RED (VPC) =====
  vpc_name          = "${local.app_name}-vpc"
  vpc_cidr          = "10.0.0.0/16"
  subnet_cidr       = "10.0.1.0/24"
  subnet_name       = "${local.app_name}-subnet"
  vpc_connector_name = "${local.app_name}-vcon"

  # ===== BASE DE DATOS =====
  db_instance_name = "${local.app_name}-db"
  db_name          = "DemoApi"
  db_user          = "psqluser"
  db_tier          = "db-f1-micro"      # Micro para pruebas (costo bajo)
  db_disk_size     = 10                 # GB
  db_version       = "POSTGRES_15"

  # ===== SECRET MANAGER =====
  secret_name = "${local.app_name}-db-secret"

  # ===== CLOUD RUN =====
  cloud_run_name   = "${local.app_name}-api"
  cloud_run_memory = "512Mi"
  cloud_run_cpu    = "1"
  cloud_run_concurrency = 80

  # ===== ARTIFACT REGISTRY =====
  registry_name     = "${local.app_name}-repo"
  registry_location = var.region

  # ===== GLOBAL LOAD BALANCER =====
  lb_name = "${local.app_name}-lb"
}