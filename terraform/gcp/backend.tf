terraform {
  backend "gcs" {
    bucket  = "tf-state-gcp-app-conf"           # Nombre del bucket (debe existir)
    prefix  = "gcp/infrastructure"              # Carpeta dentro del bucket
    # encrypt = true                           # Encriptación automática en GCS
  }
}

# NOTA: El bucket debe existir antes de ejecutar 'terraform init'
# gcloud storage buckets create gs://tf-state-gcp-app-conf --location=us-central1