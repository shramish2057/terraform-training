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
##  GitHub Actions Terraform CI/CD Pipeline

This repository includes a fully automated **CI/CD pipeline** built using **GitHub Actions** to handle infrastructure provisioning via **Terraform**.

The workflow is defined in:

```text
.github/workflows/terraform.yml
```

## 📌 Workflow Overview

| Step | Description |
|------|-------------|
| Checkout | Fetches the latest source code from the repository |
| Setup Terraform | Installs Terraform CLI (version pinned via env.TF_VERSION) |
| AWS Credentials Injection | Uses secrets to authenticate with AWS |
| Environment Debug | Verifies that all required TF_VAR_* are injected |
| Terraform Format | Checks formatting using terraform fmt |
| Terraform Init | Initializes the backend and modules |
| Terraform Validate | Validates Terraform code syntax and semantics |
| Terraform Plan | Generates and stores an execution plan (tfplan) |
| Terraform Apply | Automatically applies the plan (only on push to main) |

## 🧪 Trigger Conditions

The workflow is triggered on:

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

## 🔐 Required Secrets in GitHub

Go to your repository → Settings → Secrets and variables → Actions → New repository secret.

| Secret Name | Purpose |
|-------------|---------|
| AWS_ACCESS_KEY_ID | AWS IAM Access Key for CI/CD |
| AWS_SECRET_ACCESS_KEY | AWS IAM Secret Key |
| TF_VAR_account_id | Used by Terraform to set IAM/account context |
| TF_VAR_db_password | Password used for RDS DB provisioning |

## 📁 Pipeline File: .github/workflows/terraform.yml

### Key Environment Variables

```yaml
env:
  TF_VERSION: 1.4.6
  AWS_REGION: us-east-1
```

### Example Snippet (Configure AWS + Terraform Init):

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ env.AWS_REGION }}

- name: Terraform Init
  run: terraform init
```

### Conditional Apply (Only on Push to main)

```yaml
- name: Terraform Apply (Main Only)
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: terraform apply -input=false -auto-approve tfplan
```

## 🔁 Reusable Workflow Logic

The pipeline is built to be idempotent:

- Pushing updates to main will re-provision and apply changes.
- Pull requests run plan but do not apply — enabling preview and safety.

## ✅ Before You Run

Ensure the following:

- terraform init has been run at least once manually to bootstrap backend (S3 + DynamoDB)
- AWS secrets are properly configured in GitHub Actions
- You've built or referenced the correct AMI ID in your .tfvars 

---
## Notes & Best Practices

- RDS uses deletion_protection = true - disable for full teardown

- EC2 AMI is built once and reused - change windows_ami_id if needed

- Use terraform destroy with caution

- Extend for dev/staging/prod via workspaces or directories

## Thank You
This setup was built with a strong focus on professional infrastructure practices. Use it as a base for real projects, teams, or self training.



