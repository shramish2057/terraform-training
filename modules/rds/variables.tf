variable "subnet_ids" {
  description = "List of subnet IDs to use for the RDS subnet group"
  type        = list(string)
}

variable "sg_id" {
  description = "Security group ID for the RDS instance"
  type        = string
}

variable "db_username" {
  description = "Master username for the PostgreSQL DB"
  type        = string
}

variable "db_password" {
  description = "Master password for the PostgreSQL DB"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name to create"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.m6i.xlarge"
}

variable "allocated_storage" {
  description = "Storage in GB for the RDS instance"
  type        = number
  default     = 100
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Common tags to apply"
  type        = map(string)
  default     = {}
}

variable "run_init_sql" {
  description = "Whether to run the DB initialization SQL script"
  type        = bool
  default     = false
}
