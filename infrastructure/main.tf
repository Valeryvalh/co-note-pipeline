provider "aws" {
  region = "us-east-1"
}

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for Co-note S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  #checkov:skip=CKV2_AWS_64:Default AWS account root KMS key policy is sufficient for lab scope
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-app-secure-bucket-12345"
  #checkov:skip=CKV_AWS_144:Single-region lab environment; cross-region replication not required
  #checkov:skip=CKV2_AWS_62:Event notifications not required for this lab storage bucket
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_crypto" {
  bucket = aws_s3_bucket.secure_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "secure_bucket_access" {
  bucket                  = aws_s3_bucket.secure_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "secure_bucket_logging" {
  bucket        = aws_s3_bucket.secure_bucket.id
  target_bucket = aws_s3_bucket.secure_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "secure_bucket_lifecycle" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "cleanup-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}