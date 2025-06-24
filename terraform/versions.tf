# Required Terraform version
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure backend for production
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "csv-processor/terraform.tfstate"
  #   region = "eu-north-1"
  #   encrypt = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}
