# Terraform Infrastructure for CSV Processor

This directory contains Terraform configuration for deploying the CSV Processor application infrastructure on AWS.

## Architecture

- **EKS Cluster**: Kubernetes cluster for running the application
- **VPC**: Network infrastructure with public and private subnets
- **S3 Bucket**: Storage for uploaded CSV files
- **IAM Roles**: Service account roles for secure access to AWS services

## Files

- `eks.tf` - EKS cluster, VPC, and IAM role configurations
- `s3.tf` - S3 bucket with intelligent lifecycle management (Standard → Standard-IA → Glacier → Deep Archive)
- `variables.tf` - Input variables for the configuration
- `versions.tf` - Terraform and provider version constraints
- `terraform.tfvars.example` - Example values for variables

## S3 Storage Configuration

The S3 bucket includes intelligent lifecycle management to optimize storage costs:

- **Automatic Transitions**: Files move through storage classes based on age
- **Cost Optimization**: Up to 95% cost reduction for long-term storage
- **Compliance**: 7-year retention with automatic cleanup
- **Security**: Server-side encryption and public access blocking

**Storage Lifecycle**:
- 0-30 days: Standard storage
- 30-90 days: Standard-IA (Infrequent Access)
- 90-365 days: Glacier
- 365+ days: Deep Archive
- 7 years: Automatic deletion

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Create variables file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your desired values
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

5. **Configure kubectl**:
   ```bash
   aws eks --region <region> update-kubeconfig --name <cluster-name>
   ```
