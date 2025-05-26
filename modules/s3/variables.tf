variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  type        = string
}

variable "rds_role_arn" {
  description = "ARN of the RDS IAM role"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
} 