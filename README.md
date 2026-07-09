# Linktic Multi-Cloud Active-Active Demo

##  Descripción del Proyecto

Este proyecto demuestra una arquitectura **multi-cloud activo-activo** desplegada en **GCP y AWS**, 
con failover automático a nivel de DNS usando **Cloudflare**. La aplicación consiste en una API REST (FastAPI) con frontend HTML y base de datos PostgreSQL, desplegada de forma independiente en cada nube.
---

## Tecnologías Utilizadas

| Componente | GCP | AWS |
|------------|-----|-----|
| **Compute** | Cloud Run | ECS Fargate |
| **Database** | Cloud SQL (PostgreSQL) | RDS (PostgreSQL) |
| **Registry** | Artifact Registry | ECR |
| **Gateway** | Global Load Balancer (GCLB) | Application Load Balancer (ALB) |
| **Secrets** | Secret Manager | Secrets Manager |
| **Network** | VPC + VPC Connector | VPC + Private Subnets |
| **DNS + Failover** | Cloudflare (Weighted 50/50) | |

---

## Prerrequisitos

### Locales
- [ ] Docker y Docker Compose
- [ ] Terraform (>= 1.5)
- [ ] gcloud CLI (GCP)
- [ ] aws CLI (AWS)
- [ ] GitHub CLI (opcional)
- [ ] curl (para pruebas)

### Cuentas
- [ ] GCP: Proyecto activo con facturación habilitada
- [ ] AWS: Cuenta con crédito $200 (demo)
- [ ] Cloudflare: Cuenta gratuita

---

##  Configuración Inicial

### 1. Clonar el repositorio
bash
git clone https://github.com/tu-usuario/linktic-multicloud.git
cd linktic-multicloud
2. Configurar credenciales
GCP:

bash
gcloud auth login
gcloud config set project gcp-msapp
AWS:

bash
aws configure --profile linktic-multicloud
Cloudflare:

Generar API Token con permisos Edit zone DNS

Guardar CLOUDFLARE_API_TOKEN y CLOUDFLARE_ZONE_ID

3. Configurar secrets en GitHub
bash
gh secret set GCP_PROJECT_ID --body "gcp-msapp"
gh secret set GCP_REGION --body "us-central1"
gh secret set GCP_SA_KEY --body "$(cat ~/.gcp/gcp-terraform-key.json)"
gh secret set AWS_ACCESS_KEY_ID --body "AKIA..."
gh secret set AWS_SECRET_ACCESS_KEY --body "..."
gh secret set AWS_REGION --body "us-west-2"
gh secret set CLOUDFLARE_API_TOKEN --body "..."
gh secret set CLOUDFLARE_ZONE_ID --body "..."

# Ejecución Local (Desarrollo)
Con Docker Compose
bash
docker-compose up -d
API: http://localhost:8000

Frontend: http://localhost:8000

Probar localmente
bash
curl http://localhost:8000/health
curl -X POST http://localhost:8000/api/items -H "Content-Type: application/json" -d '{"name":"Test","description":"Local"}'
 Despliegue en Nubes
GCP (Terraform)
bash
cd terraform/gcp
terraform init
terraform plan -var="service_name=gcp-mcapp" -var="project_id=gcp-msapp" -var="db_password=Colombia2026"
terraform apply -var="service_name=gcp-mcapp" -var="project_id=gcp-msapp" -var="db_password=Colombia2026" -auto-approve
Outputs:

gateway_ip: IP pública del GCLB

cloud_run_url: URL de Cloud Run

database_private_ip: IP privada de Cloud SQL

AWS (Terraform)
bash
cd terraform/aws
terraform init
terraform plan -var="app_name=aws-mcapp" -var="db_password=Colombia2026"
terraform apply -var="app_name=aws-mcapp" -var="db_password=Colombia2026" -auto-approve
Outputs:

alb_dns_name: DNS del ALB

ec2_public_ip: IP pública de EC2 (si aplica)

rds_address: Endpoint de RDS

 CI/CD (GitHub Actions)
Workflows disponibles:

deploy-gcp.yml: Build + Push + Deploy a Cloud Run

deploy-aws.yml: Build + Push + Deploy a ECS Fargate

Trigger:

bash
git commit --allow-empty -m "chore: trigger deployment"
git push origin main
Verificar:

GitHub → Actions → Ver logs de build y deploy

 DNS + Failover (Cloudflare)
Configuración en UI
Health Check: Path /health, Port 8000

Pool: AWS-GCP con endpoints:

GCP: 34.117.95.21 (GCLB IP)

AWS: aws-mcapp-alb-756554178.us-west-2.elb.amazonaws.com (ALB DNS)

Weighted Routing: Weight = 1 en ambos (50/50)

Steering Policy: Random

Probar Failover
bash
# Simular caída de GCP
gcloud run services delete gcp-mcapp-api --region=us-central1 --project=gcp-msapp --quiet

# Verificar en Cloudflare (UI)
# gcp-api debe pasar a "Critical"

# Restaurar GCP
gcloud run deploy gcp-mcapp-api --image us-central1-docker.pkg.dev/gcp-msapp/gcp-mcapp-repo/gcp-mcapp-api:latest --region=us-central1 --platform managed --allow-unauthenticated --project=gcp-msapp
 Pruebas de API
Endpoints GCP (GCLB)
Operación	Comando
Health Check	curl http://"IP_GENERADA"/health
Crear item	curl -X POST http://"IP_GENERADA"/api/items -H "Content-Type: application/json" -d '{"name":"GCP-Item","description":"Creado en GCP"}'
Listar items	curl http://"IP_GENERADA"/api/items
Endpoints AWS (ALB)
Operación	Comando
Health Check	curl http://aws-mcapp-alb-"ID_AWS".us-west-2.elb.amazonaws.com/health
Crear item	curl -X POST http://aws-mcapp-alb-"ID_AWS".us-west-2.elb.amazonaws.com/api/items -H "Content-Type: application/json" -d '{"name":"AWS-Item","description":"Creado en AWS"}'
Listar items	curl http://aws-mcapp-alb-"ID_AWS".us-west-2.elb.amazonaws.com/api/items
 Destruir Infraestructura
GCP
bash
cd terraform/gcp
terraform destroy -var="service_name=gcp-mcapp" -var="project_id=gcp-msapp" -var="db_password=Colombia2026" -auto-approve
AWS
bash
cd terraform/aws
terraform destroy -var="app_name=aws-mcapp" -var="db_password=Colombia2026" -auto-approve
Local
bash
docker-compose down -v
 Resumen de Recursos
Cloud	Recursos	Costo estimado/mes
GCP	Cloud Run, Cloud SQL (micro), Artifact Registry, GCLB, VPC Connector	~$10 USD
AWS	ECS Fargate, RDS (micro), ECR, ALB, VPC, NAT Gateway	~$15 USD
Cloudflare	DNS, Health Checks, Weighted Routing	Gratuito
 Seguridad
Zero secrets en repositorio: Uso de Secret Manager / Secrets Manager

BD privada: No expuesta a internet (IP privada + VPC)

IAM least privilege: Roles mínimos por recurso

HTTPS: Configurable en gateway (pendiente para producción)

Notas Adicionales
Portabilidad: La misma imagen Docker funciona en GCP y AWS (usando PORT variable).

Rollback: En Cloud Run: gcloud run deploy --image=versión-anterior. En ECS: aws ecs update-service --task-definition=versión-anterior.

Logs: GCP (Cloud Logging), AWS (CloudWatch).
