variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID for role trust"
  type        = string
}

variable "user_name" {
  description = "IAM user name who can assume the role"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
