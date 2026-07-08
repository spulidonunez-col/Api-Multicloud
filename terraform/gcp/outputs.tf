# =============================================
# outputs.tf (parcial - solo BD)
# Salidas para la base de datos
# =============================================

output "database_private_ip" {
  description = "IP privada de Cloud SQL (accesible desde la VPC)"
  value       = google_sql_database_instance.main.private_ip_address
  sensitive   = false
}

output "database_name" {
  description = "Nombre de la base de datos"
  value       = local.db_name
}

output "database_user" {
  description = "Usuario de la base de datos"
  value       = local.db_user
  sensitive   = true
}

output "secret_name" {
  description = "Nombre del secret en Secret Manager"
  value       = google_secret_manager_secret.db_password.secret_id
}

# === SALIDAS DE CLOUD RUN ===
output "cloud_run_url" {
  description = "URL interna de Cloud Run"
  value       = google_cloud_run_v2_service.main.uri
}

output "cloud_run_name" {
  description = "Nombre del servicio Cloud Run"
  value       = google_cloud_run_v2_service.main.name
}

# === SALIDAS DE GATEWAY ===
output "gateway_ip" {
  description = "IP pública del Global Load Balancer (GCLB)"
  value       = google_compute_global_address.main.address
}

output "gateway_url" {
  description = "URL del Gateway (HTTPS)"
  value       = "https://${google_compute_global_address.main.address}/"
}