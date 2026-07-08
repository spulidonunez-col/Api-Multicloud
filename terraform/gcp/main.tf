# ==================== ARTIFACT REGISTRY ====================
resource "google_artifact_registry_repository" "main" {
  location      = local.registry_location
  repository_id = local.registry_name
  format        = "DOCKER"
  description   = "Docker repository for gcp demo app"
}

# ==================== CLOUD SQL ====================
resource "google_sql_database_instance" "main" {
  name             = "${local.app_name}-db"
  database_version = local.db_version
  region           = var.region
  
  settings {
    tier              = local.db_tier
    disk_size         = local.db_disk_size
    disk_autoresize   = false
    availability_type = "ZONAL"
    
    ip_configuration {
      private_network = "projects/${var.project_id}/global/networks/${local.vpc_network}"
      authorized_networks {
        name  = "allow-cloud-run"
        value = "0.0.0.0/0"  # Solo para pruebas
      }
    }
  }
  
  deletion_protection = false
}

resource "google_sql_database" "main" {
  name     = "DemoApi"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "main" {
  name     = "psqluser"
  instance = google_sql_database_instance.main.name
  password = var.db_password
}

# ==================== CLOUD RUN ====================
resource "google_cloud_run_v2_service" "main" {
  name     = var.service_name
  location = local.cloud_run_location
  
  template {
    containers {
      image = "${local.registry_location}-docker.pkg.dev/${var.project_id}/${local.registry_name}/${var.service_name}:latest"
      
      env {
        name  = "DATABASE_URL"
        value = "postgresql://psqluser:${var.db_password}@${google_sql_database_instance.main.public_ip_address}:5432/DemoApi"
      }
      
      env {
        name  = "ENVIRONMENT"
        value = "production"
      }
      
      resources {
        limits = {
          cpu    = local.cloud_run_cpu
          memory = local.cloud_run_memory
        }
      }
    }
    
    max_instance_request_concurrency = local.cloud_run_concurrency
    
    scaling {
      max_instance_count = 5
      min_instance_count = 1
    }
  }
  
  ingress = "INGRESS_TRAFFIC_ALL"
  
  depends_on = [
    google_sql_database_instance.main,
    google_artifact_registry_repository.main
  ]
}

# ==================== PERMITIR ACCESO ANÓNIMO ====================
resource "google_cloud_run_v2_service_iam_binding" "public" {
  project  = var.project_id
  location = local.cloud_run_location
  name     = google_cloud_run_v2_service.main.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}