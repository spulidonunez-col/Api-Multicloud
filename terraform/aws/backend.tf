# =============================================
# backend.tf
# State remoto en S3 con bloqueo DynamoDB
# =============================================

terraform {
  backend "s3" {
    bucket         = "tf-state-aws-mcapp"
    key            = "aws/infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# NOTA: El bucket y la tabla DynamoDB deben existir previamente.
# Puede crearlos manualmente o con un script:
# aws s3 mb s3://tf-state-aws-mcapp --region us-east-1
# aws dynamodb create-table --table-name terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region us-east-1