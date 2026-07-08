terraform {
  backend "s3" {
    bucket         = "tf-state-linktic-aws-XXXX"
    key            = "aws/environments/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
   }
}