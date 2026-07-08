# =============================================
# network.tf
# Red privada (VPC), subred y VPC Connector
# El VPC Connector permite a Cloud Run acceder a Cloud SQL vía IP privada
# =============================================

# 1. VPC (Red Virtual Privada)
resource "google_compute_network" "main" {
  name                    = local.vpc_name
  auto_create_subnetworks = false               # Creamos subredes manualmente
  routing_mode            = "REGIONAL"          # Enrutamiento dentro de la región
  project                 = var.project_id
}

# 2. Subred dentro de la VPC
resource "google_compute_subnetwork" "main" {
  name          = local.subnet_name
  ip_cidr_range = local.subnet_cidr
  region        = var.region
  network       = google_compute_network.main.id
  project       = var.project_id
}

# 3. VPC Connector (permite conexión privada desde Cloud Run a Cloud SQL)
# El rango IP debe ser /28 como mínimo
resource "google_vpc_access_connector" "main" {
  provider = google-beta

  name          = local.vpc_connector_name
  region        = var.region
  project       = var.project_id
  network       = google_compute_network.main.name
  ip_cidr_range = "10.8.0.0/28"                # Rango mínimo para el conector

  # El conector debe estar en funcionamiento antes de que Cloud Run lo use
  # Se indica explícitamente para que Terraform espere
  depends_on = [google_compute_network.main]
}