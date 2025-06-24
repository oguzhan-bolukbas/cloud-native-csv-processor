# Terraform Infrastructure for CSV Processor

This directory contains Terraform configuration for deploying the CSV Processor application infrastructure on AWS.

## Architecture

- **EKS Cluster**: Kubernetes cluster for running the application
- **VPC**: Network infrastructure with public and private subnets
- **S3 Bucket**: Storage for uploaded CSV files
- **IAM Roles**: Service account roles for secure access to AWS services

## Files

- `eks.tf` - EKS cluster, VPC, and IAM role configurations
- `s3.tf` - S3 bucket for CSV file storage
- `variables.tf` - Input variables for the configuration
- `versions.tf` - Terraform and provider version constraints
- `terraform.tfvars.example` - Example values for variables

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
