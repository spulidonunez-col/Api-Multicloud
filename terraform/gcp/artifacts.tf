resource "google_project_service" "artifactregistry" {
  provider = google-beta

  project = var.project_id
  service = "artifactregistry.googleapis.com"

  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "main" {
  provider = google-beta

  location      = local.registry_location
  repository_id = local.registry_name
  format        = "DOCKER"
  description   = "Docker repository for ${local.app_name}"

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-old-versions"
    action = "DELETE"
    condition {
      older_than = "259200s"
    }
  }

  labels = {
    app       = local.app_name
    managed   = "terraform"
    project   = var.project_id
    region    = var.region
  }

  depends_on = [google_project_service.artifactregistry]
}

resource "google_artifact_registry_repository_iam_member" "cloud_run_access" {
  provider = google-beta

  project    = var.project_id
  location   = local.registry_location
  repository = google_artifact_registry_repository.main.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"

  depends_on = [google_artifact_registry_repository.main]
}

resource "google_artifact_registry_repository_iam_member" "terraform_access" {
  provider = google-beta

  project    = var.project_id
  location   = local.registry_location
  repository = google_artifact_registry_repository.main.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${var.service_account_email}"

  depends_on = [google_artifact_registry_repository.main]
}

resource "google_artifact_registry_repository_iam_policy" "security" {
  provider = google-beta

  project    = var.project_id
  location   = local.registry_location
  repository = google_artifact_registry_repository.main.name

  policy_data = data.google_iam_policy.artifact_registry_policy.policy_data

  depends_on = [google_artifact_registry_repository.main]
}

data "google_iam_policy" "artifact_registry_policy" {
  binding {
    role = "roles/artifactregistry.reader"
    members = [
      "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com",
      "serviceAccount:${var.service_account_email}"
    ]
  }

  binding {
    role = "roles/artifactregistry.writer"
    members = [
      "serviceAccount:${var.service_account_email}"
    ]
  }
}