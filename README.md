# Terraform Infrastructure as Code (IaC)

## Overview

This repository contains Terraform code for provisioning and managing AWS infrastructure to support a web application. The infrastructure includes a Virtual Private Cloud (VPC), public and private subnets, security groups, an Application Load Balancer (ALB), Auto Scaling Group (ASG), and more. This setup is designed to create a scalable and reliable environment for a web application.

## Requirements

Before using this Terraform code, ensure you have the following prerequisites in place:

- [Terraform](https://www.terraform.io/downloads.html) installed.
- AWS CLI configured with appropriate credentials (AWS Access Key ID and Secret Access Key) or IAM roles.

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/terraform-aws-webapp.git
   cd terraform-aws-webapp

2. Initialize Terraform:
   
```
terraform init
```
Review and customize the terraform.tfvars, variables.tf and main.tf files according to your project requirements.

3.Plan the resources:
```
terraform plan -var-file=".\terraform.tfvars" -out="infra-tfplan"
```

4. Deploy the infrastructure:

```
terraform apply -var-file=".\terraform.tfvars" -out="infra-tfplan"
```
Confirm and approve the changes when prompted.
