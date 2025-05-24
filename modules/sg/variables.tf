variable "vpc_id" {
  description = "VPC ID to attach security groups to"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR block (your IP) allowed to RDP into EC2"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all security groups"
  type        = map(string)
  default     = {}
}
