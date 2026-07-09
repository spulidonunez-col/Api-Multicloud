# 1. Instancia de Cloud SQL
resource "google_sql_database_instance" "main" {
  provider = google-beta

  name             = local.db_instance_name
  database_version = local.db_version
  region           = var.region
  project          = var.project_id

  deletion_protection = false

  settings {
    tier              = local.db_tier
    disk_size         = local.db_disk_size
    disk_autoresize   = false
    availability_type = "ZONAL"          # Para HA regional usar "REGIONAL"

    # Configuración de red: IP PRIVADA (no pública)
    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/default"
    }

    # Backup automático (retención 7 días)
    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = false
      transaction_log_retention_days = 7
    }
  }

  # Dependencia explícita: la VPC debe existir antes de crear la BD
  depends_on = [google_compute_network.main]
}

# 2. Base de datos dentro de la instancia
resource "google_sql_database" "main" {
  name     = local.db_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# 3. Usuario de la base de datos
resource "google_sql_user" "main" {
  name     = local.db_user
  instance = google_sql_database_instance.main.name
  password = var.db_password
  project  = var.project_id
}