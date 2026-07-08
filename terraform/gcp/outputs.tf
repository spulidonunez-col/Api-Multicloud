output "cloud_run_url" {
  description = "URL del servicio Cloud Run"
  value       = google_cloud_run_v2_service.main.uri
}

output "cloud_run_ip" {
  description = "IP pública del Cloud Run"
  value       = google_cloud_run_v2_service.main.uri
}

output "database_public_ip" {
  description = "IP pública de Cloud SQL"
  value       = google_sql_database_instance.main.public_ip_address
  sensitive   = true
}

output "artifact_registry_repo" {
  description = "Repositorio de Artifact Registry"
  value       = "${local.registry_location}-docker.pkg.dev/${var.project_id}/${local.registry_name}"
}