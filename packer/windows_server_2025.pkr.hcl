packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "m7i.2xlarge"
}

variable "ami_name" {
  type    = string
  default = "windows2025-devops-{{timestamp}}"
}

source "amazon-ebs" "windows" {
  region                  = var.aws_region
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Full-Base-*"
      virtualization-type = "hvm"
      architecture         = "x86_64"
    }
    owners      = ["801119661308"]
    most_recent = true
  }

  ami_name               = var.ami_name
  instance_type          = var.instance_type
  communicator           = "winrm"
  winrm_username         = "Administrator"
  winrm_use_ssl          = true
  winrm_insecure         = true
  winrm_port             = 5986
  associate_public_ip_address = true
  user_data_file         = "./scripts/winrm_setup.ps1"
}

build {
  name    = "windows-server-2025"
  sources = ["source.amazon-ebs.windows"]

  provisioner "powershell" {
    scripts = [
      "./scripts/install_pbi.ps1",
      "./scripts/install_java.ps1",
      "./scripts/install_python.ps1",
      "./scripts/install_gocd.ps1"
    ]
  }
}
