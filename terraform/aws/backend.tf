terraform {
  backend "s3" {
    bucket         = "tf-state-aws-202607"
    key            = "aws/environments/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
   }
}