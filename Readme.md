# AWS DevOps Terraform Infrastructure – Training Project

This repository contains a **complete, production-grade Infrastructure-as-Code (IaC) setup using Terraform, Packer, and GitHub Actions** to provision a full AWS environment. It is designed for DevOps training and automation best practices.

---

## Features

- **Remote backend (S3 + DynamoDB)** for safe Terraform state handling
- **Modular Terraform structure**: VPC, RDS, EC2, Security Groups, ELB + ASG
- **CI/CD pipeline** using GitHub Actions to lint, plan, and apply Terraform
- **Packer build** for a custom Windows Server 2025 AMI with:
  - Power BI Desktop
  - Power BI Gateway
  - Adoptium Java
  - Python
  - GoCD Server and Agent
- **Secure defaults**: VPC isolation, no public RDS, encryption, tagging
- **Step-by-step bootstrap and deployment workflow**

---

## 📁 Folder Structure

```text
aws-terraform-devops/
├── backend.tf            # Remote state config (S3 + DynamoDB)
├── providers.tf          # Provider and default tags
├── variables.tf          # Global variables
├── terraform.tfvars      # Default values (region, env, etc.)
├── outputs.tf
├── main.tf               # Root module wiring
├── modules/              # Reusable Terraform modules
│   ├── vpc/
│   ├── sg/
│   ├── rds/
│   ├── ec2/
│   └── elb_asg/
├── bootstrap/            # Bootstraps backend infra
│   └── main.tf / variables.tf / outputs.tf
├── packer/
│   ├── windows_server_2025.pkr.hcl
│   └── scripts/         # Software install scripts (Power BI, GoCD, etc.)
├── .github/workflows/
│   └── terraform.yml    # GitHub Actions CI/CD pipeline
├── scripts/
│   └── user_data.ps1    # Bootstrap EC2 setup (optional)
└── README.md

## Step-by-Step Testing Guide

Follow these steps **in order** to safely test and apply the infrastructure:

---

### Step 1: Bootstrap Remote Backend (once per environment)

```bash
cd bootstrap
terraform init
terraform apply
```

This creates the S3 bucket and DynamoDB table required for locking and state storage.

---

###  Step 2: Configure Terraform Backend
Ensure backend.tf contains:

```bash
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod-001"
    key            = "devops/windows-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```
---
### Step 3: Build Custom Windows AMI with Packer (Or alternatively use official AMI from AWS for us-east-1 (N. Virginia). AMI is: Windows_Server-2022-English-Full-Base-2023.11.15)
``` bash
cd packer
packer init .
packer build .
```
Copy the resulting AMI ID into terraform.tfvars as:

```hcl
windows_ami_id = "ami-0abcd1234example"
```
---
### Step 4: Initialize and Plan Terraform
```bash
cd ../
terraform init
terraform plan
```
Check all resources are being created as expected.

---
### Step 5: Apply Infrastructure
```bash
terraform apply
```
This will deploy:

- VPC with 2 public subnets

- Security Groups (EC2, RDS, ELB)

- RDS PostgreSQL Multi-AZ

- EC2 with custom AMI

- Application Load Balancer with Auto Scaling Group

---
### Step 6: CI/CD via GitHub Actions (Optional)
```bash
git add .
git commit -m "Deploy infrastructure"
git push origin main
```
Ensure the following GitHub secrets are set:

### Secret	Description
AWS_ACCESS_KEY_ID	AWS credentials
AWS_SECRET_ACCESS_KEY	AWS credentials
TF_VAR_db_password	Optional secret var for DB password

---
###  Step 7: Access Outputs
bash
terraform output
This includes:

- RDS endpoint

- EC2 public IP

- ALB DNS name

---
Notes & Best Practices

- RDS uses deletion_protection = true - disable for full teardown

- EC2 AMI is built once and reused - change windows_ami_id if needed

- Use terraform destroy with caution

- Extend for dev/staging/prod via workspaces or directories

### Cleanup
```bash
terraform destroy
```

For backend infra cleanup:

```bash
cd bootstrap
terraform destroy
```

### 🙌 Thank You
This setup was built with a strong focus on professional infrastructure practices. Use it as a base for real projects, teams, or internal IaC training.



