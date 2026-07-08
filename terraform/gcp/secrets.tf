# =============================================
# secrets.tf
# =============================================

# Obtener el número del proyecto
data "google_project" "project" {
  project_id = var.project_id
}

# 1. Crear el secret
resource "google_secret_manager_secret" "db_password" {
  provider = google-beta

  secret_id = local.secret_name
  project   = var.project_id

  replication {
    auto {}
  }

  labels = {
    app     = local.app_name
    managed = "terraform"
  }
}

# 2. Guardar la contraseña
resource "google_secret_manager_secret_version" "db_password" {
  provider = google-beta

  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password

  depends_on = [google_secret_manager_secret.db_password]
}

# 3. Permitir que Cloud Run lea el secret
resource "google_secret_manager_secret_iam_member" "cloud_run_access" {
  provider = google-beta

  project    = var.project_id
  secret_id  = google_secret_manager_secret.db_password.secret_id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}