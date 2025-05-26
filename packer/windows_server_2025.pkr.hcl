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
      architecture        = "x86_64"
    }
    owners      = ["801119661308"]
    most_recent = true
  }

  ami_name               = var.ami_name
  instance_type          = var.instance_type
  communicator           = "winrm"
  winrm_username         = "Administrator"
  winrm_use_ssl          = false
  winrm_insecure         = true
  winrm_port             = 5985
  associate_public_ip_address = true
  winrm_timeout          = "1h"
  security_group_id      = "sg-05469c13a78f2c081"

  user_data = <<EOF
<powershell>
# Enable detailed logging
$logFile = "C:\Windows\Temp\winrm-setup.log"
Start-Transcript -Path $logFile -Force

Write-Output "Starting WinRM setup..."

# Enable WinRM
Write-Output "Running winrm quickconfig..."
winrm quickconfig -quiet
Write-Output "Quickconfig completed"

Write-Output "Configuring WinRM settings..."
Set-Item -Force WSMan:\localhost\Service\AllowUnencrypted $true
Set-Item -Force WSMan:\localhost\Service\Auth\Basic $true
Enable-PSRemoting -Force
Write-Output "Basic WinRM configuration completed"

# Open the WinRM ports in the Windows Firewall
Write-Output "Configuring Windows Firewall..."
New-NetFirewallRule -DisplayName "WinRM HTTP" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow
Write-Output "Firewall rule for port 5985 added"

# Set timeout and memory settings
Write-Output "Setting WinRM timeouts..."
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
Write-Output "Timeout settings configured"

# Configure WinRM for Packer
Write-Output "Configuring WinRM for Packer..."
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Write-Output "Packer configuration completed"

# Restart WinRM service
Write-Output "Restarting WinRM service..."
Restart-Service WinRM
Write-Output "WinRM service restarted"

# Wait for WinRM to be ready
Write-Output "Waiting for WinRM to be ready..."
$retryCount = 0
$maxRetries = 10
$success = $false

while (-not $success -and $retryCount -lt $maxRetries) {
    try {
        Write-Output "Testing WinRM connection (Attempt $($retryCount + 1) of $maxRetries)..."
        $result = Test-WSMan -ErrorAction Stop
        $success = $true
        Write-Output "WinRM is ready and working!"
    }
    catch {
        $retryCount++
        Write-Output "WinRM test failed. Error: $_"
        Write-Output "Waiting 30 seconds before next attempt..."
        Start-Sleep -Seconds 30
    }
}

if (-not $success) {
    Write-Error "WinRM failed to start properly after $maxRetries attempts"
    Write-Output "Last error: $_"
}

Write-Output "WinRM setup script completed"
Stop-Transcript
</powershell>
EOF
}

build {
  name    = "windows-server-2025"
  sources = ["source.amazon-ebs.windows"]

  provisioner "powershell" {
    elevated_user     = "SYSTEM"
    elevated_password = ""
    pause_before      = "30s"
    scripts = [
      "./scripts/install_pbi.ps1",
      "./scripts/install_pbi_gateway.ps1",
      "./scripts/install_java.ps1",
      "./scripts/install_python.ps1",
      "./scripts/install_gocd.ps1",
      "./scripts/create_user.ps1"
    ]
  }
}
