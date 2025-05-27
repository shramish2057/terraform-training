provider "aws" {
  region = "us-east-1"  # Hardcoding temporarily for debugging
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