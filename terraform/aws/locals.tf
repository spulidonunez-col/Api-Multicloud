locals {
  app_name    = "aws-app-conf"
  environment = "production"
  
  # EC2
  instance_type = "t3.micro"
  ami_id        = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS us-east-1
  
  # RDS
  db_tier        = "db.t3.micro"
  db_disk_size   = 20
  db_engine      = "postgres"
  db_engine_version = "15"
  
  # Networking
  vpc_cidr    = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
  
  # ECR
  ecr_repo_name = "ecr-aws-app"
}