variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g. dev, prod)"
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zones to use"
  type        = list(string)
}

variable "db_password" {
  description = "Password for the RDS PostgreSQL admin user"
  type        = string
  sensitive   = true
}

variable "windows_ami_id" {
  description = "AMI ID for Windows Server"
  type        = string
}
