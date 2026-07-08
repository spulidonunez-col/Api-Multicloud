# 1. Cloud Run Service (con imagen dummy)
resource "google_cloud_run_v2_service" "main" {
  provider = google-beta

  name     = local.cloud_run_name
  location = var.region
  project  = var.project_id

  # Configuración del contenedor
  template {
    containers {
      # Imagen dummy (placeholder) - será reemplazada por CI/CD
      #image = "us-central1-docker.pkg.dev/${var.project_id}/${local.registry_name}/placeholder:latest"
      image = "gcr.io/google-samples/hello-app:1.0"
      # Recursos asignados al contenedor
      resources {
        limits = {
          cpu    = local.cloud_run_cpu
          memory = local.cloud_run_memory
        }
      }

      # Variables de entorno (valores estáticos)
      env {
        name  = "ENVIRONMENT"
        value = "production"
      }

      # Variable de entorno para la conexión a BD (usando IP privada)
      # NOTA: La contraseña se leerá desde Secret Manager en la app
      env {
        name  = "DATABASE_HOST"
        value = google_sql_database_instance.main.private_ip_address
      }
      env {
        name  = "DATABASE_NAME"
        value = local.db_name
      }
      env {
        name  = "DATABASE_USER"
        value = local.db_user
      }
    }

    # Configuración de escalado
    scaling {
      max_instance_count = 5
      min_instance_count = 1
    }

    # Timeout máximo para peticiones
    timeout = "60s"

    # Conectar a la VPC para acceder a Cloud SQL
    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "ALL_TRAFFIC"
    }
  }

  # Permitir tráfico público (HTTPS)
  ingress = "INGRESS_TRAFFIC_ALL"

  # Dependencias explícitas
  depends_on = [
    google_sql_database_instance.main,
    google_vpc_access_connector.main
  ]
}

# 2. Permitir acceso público anónimo a Cloud Run
resource "google_cloud_run_v2_service_iam_binding" "public" {
  provider = google-beta

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.main.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"  # Permite acceso público (requisito HTTPS)
  ]
}