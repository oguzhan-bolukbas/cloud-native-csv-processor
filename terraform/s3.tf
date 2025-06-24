# S3 bucket for CSV file uploads
resource "aws_s3_bucket" "csv_processor_uploads" {
  bucket = var.s3_bucket_name

  tags = merge(var.tags, {
    Name = "CSV Processor Uploads"
  })
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "csv_processor_uploads" {
  bucket = aws_s3_bucket.csv_processor_uploads.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "csv_processor_uploads" {
  bucket = aws_s3_bucket.csv_processor_uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "csv_processor_uploads" {
  bucket = aws_s3_bucket.csv_processor_uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "csv_processor_uploads" {
  bucket = aws_s3_bucket.csv_processor_uploads.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    id     = "delete-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for CSV uploads"
  value       = aws_s3_bucket.csv_processor_uploads.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for CSV uploads"
  value       = aws_s3_bucket.csv_processor_uploads.arn
}
