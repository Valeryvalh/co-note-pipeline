provider "aws" {
  region = "us-east-1"
}

# Intentional misconfiguration: No encryption, public access block, or versioning
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "my-app-insecure-bucket-12345"
}