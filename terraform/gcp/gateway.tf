# =============================================
# gateway.tf - Global Load Balancer (GCLB)
# =============================================

# 1. Health Check para Cloud Run
resource "google_compute_health_check" "cloud_run" {
  provider = google-beta

  name        = "${local.app_name}-hc"
  project     = var.project_id
  check_interval_sec  = 30
  timeout_sec         = 10

  http_health_check {
    port         = 8000
    request_path = "/health"
    proxy_header = "NONE"
  }
}

# 2. Network Endpoint Group (NEG) serverless para Cloud Run
resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  provider = google-beta

  name                  = "${local.app_name}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  project               = var.project_id

  cloud_run {
    service = google_cloud_run_v2_service.main.name
  }
}

# 3. Backend Service que usa el NEG
resource "google_compute_backend_service" "cloud_run" {
  provider = google-beta

  name        = "${local.app_name}-backend"
  project     = var.project_id
  protocol    = "HTTP"
  port_name   = "http"
  #timeout_sec = 60

  #health_checks = [google_compute_health_check.cloud_run.id]

  backend {
    group = google_compute_region_network_endpoint_group.cloud_run_neg.id
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  depends_on = [
    google_compute_region_network_endpoint_group.cloud_run_neg,
    #google_compute_health_check.cloud_run
  ]
}

# 4. Dirección IP global
resource "google_compute_global_address" "main" {
  name       = "${local.app_name}-ip"
  project    = var.project_id
  ip_version = "IPV4"
}

# 5. URL Map (enrutamiento por path)
resource "google_compute_url_map" "main" {
  provider = google-beta

  name        = "${local.app_name}-urlmap"
  project     = var.project_id

  default_service = google_compute_backend_service.cloud_run.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.cloud_run.id

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.cloud_run.id
    }

    path_rule {
      paths   = ["/health"]
      service = google_compute_backend_service.cloud_run.id
    }

    path_rule {
      paths   = ["/"]
      service = google_compute_backend_service.cloud_run.id
    }
  }
}

# 6. Target HTTP Proxy (sin SSL)
resource "google_compute_target_http_proxy" "main" {
  provider = google-beta

  name    = "${local.app_name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.main.id
}

# 7. Global Forwarding Rule (HTTP - puerto 80)
resource "google_compute_global_forwarding_rule" "main" {
  provider = google-beta

  name       = "${local.app_name}-fr"
  project    = var.project_id
  ip_address = google_compute_global_address.main.address
  port_range = "80"
  target     = google_compute_target_http_proxy.main.id
}