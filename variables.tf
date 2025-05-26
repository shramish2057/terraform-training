variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "prod"
}

variable "admin_cidr" {
  description = "CIDR block for RDP access to EC2 (e.g. your IP)"
  type        = string
}

variable "account_id" {
  description = "AWS account ID for IAM trust relationships"
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zones to use (e.g. [\"us-east-1a\", \"us-east-1b\"])"
  type        = list(string)
}

variable "db_username" {
  description = "The master username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "RDS PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "windows_ami_id" {
  description = "AMI ID for the Windows Server to use in EC2"
  type        = string
}

variable "secret_arn" {
  description = "Secret ARN for RDS credentials"
  type        = string
}

variable "run_init_sql" {
  description = "Whether to run DB init SQL script"
  type        = bool
  default     = false
}
