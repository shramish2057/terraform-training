variable "subnet_ids" {
  description = "Public subnet IDs for the ALB and ASG"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for target group"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the ASG launch template"
  type        = string
  default     = "m7i.2xlarge"
}

variable "key_name" {
  description = "Key pair name for EC2 access"
  type        = string
  default     = null
}

variable "sg_id" {
  description = "Security group to associate with EC2 instances and ALB"
  type        = string
}

variable "user_data_file" {
  description = "User data script path for EC2 bootstrap"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
