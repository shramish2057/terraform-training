variable "ami_id" {
  description = "AMI ID for Windows Server 2025 (can be from Packer)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m7i.2xlarge"
}

variable "subnet_id" {
  description = "Subnet ID to deploy the EC2 instance into"
  type        = string
}

variable "sg_id" {
  description = "Security group ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair (for RDP)"
  type        = string
  default     = null
}

variable "user_data_file" {
  description = "Path to the user data script for bootstrap"
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 100
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "tags" {
  description = "Common tags to apply"
  type        = map(string)
  default     = {}
}
