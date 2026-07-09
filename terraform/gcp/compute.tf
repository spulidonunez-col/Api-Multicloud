resource "google_cloud_run_v2_service" "main" {
  provider = google-beta

  name     = local.cloud_run_name
  location = var.region
  project  = var.project_id

  template {
    containers {
      
      #image = "${local.registry_location}-docker.pkg.dev/${var.project_id}/${local.registry_name}/${local.cloud_run_name}:latest"
      image = "gcr.io/google-samples/hello-app:1.0"
      
      resources {
        limits = {
          cpu    = local.cloud_run_cpu
          memory = local.cloud_run_memory
        }
      }

      # Variables de entorno
      env {
        name  = "ENVIRONMENT"
        value = "production"
      }
      env {
        name  = "DATABASE_URL"
        value = "postgresql://${local.db_user}:${var.db_password}@${google_sql_database_instance.main.private_ip_address}/${local.db_name}"
      }    
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

    scaling {
      max_instance_count = 5
      min_instance_count = 1
    }

    timeout = "60s"

    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "ALL_TRAFFIC"
    }
  }

  ingress = "INGRESS_TRAFFIC_ALL"

  depends_on = [
    google_sql_database_instance.main,
    google_vpc_access_connector.main
  ]
}

resource "google_cloud_run_v2_service_iam_binding" "public" {
  provider = google-beta

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.main.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}