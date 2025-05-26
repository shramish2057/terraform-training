provider "aws" {
  region = var.aws_region
  alias  = "s3"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
} 