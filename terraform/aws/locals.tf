# =============================================
# locals.tf
# Valores fijos para AWS
# =============================================

locals {
  app_name = var.app_name

  # ===== RED (VPC) =====
  vpc_cidr          = "10.0.0.0/16"
  public_subnet_a   = "10.0.1.0/24"
  public_subnet_b   = "10.0.2.0/24"
  private_subnet_a  = "10.0.3.0/24"
  private_subnet_b  = "10.0.4.0/24"

  # Nombres de recursos
  vpc_name          = "${local.app_name}-vpc"
  igw_name          = "${local.app_name}-igw"
  public_rt_name    = "${local.app_name}-public-rt"
  private_rt_name   = "${local.app_name}-private-rt"

  # ===== RDS =====
  db_instance_name = "${local.app_name}-db"
  db_name          = "DemoApi"
  db_user          = "psqluser"
  db_tier          = "db.t4g.micro"
  db_disk_size     = 20
  db_engine        = "postgres"
  db_engine_version = "15"

  # ===== ECS FARGATE =====
  service_name     = "${local.app_name}-api"
  task_family      = "${local.app_name}-task"
  container_name   = "${local.app_name}-container"
  cpu              = "256"
  memory           = "512"

  # ===== ECR =====
  repo_name = "${local.app_name}-repo"

  # ===== ALB =====
  alb_name = "${local.app_name}-alb"
  tg_name  = "${local.app_name}-tg"
}