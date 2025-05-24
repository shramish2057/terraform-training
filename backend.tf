terraform {
  backend "s3" {
    bucket         = "tf-state-prod-shramish-training"
    key            = "devops/windows-infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-locks-prod-shramish-training"
  }
}