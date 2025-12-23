terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# Generate random 4 letter suffix
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

# S3 Bucket
resource "aws_s3_bucket" "sensitive" {
  bucket        = "wsc2025-sensitive-${random_string.suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "sensitive" {
  bucket = aws_s3_bucket.sensitive.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Upload source files to incoming prefix
resource "aws_s3_object" "names" {
  bucket = aws_s3_bucket.sensitive.id
  key    = "incoming/names.txt"
  source = "${path.module}/src/names.txt"
  etag   = filemd5("${path.module}/src/names.txt")
}

resource "aws_s3_object" "emails" {
  bucket = aws_s3_bucket.sensitive.id
  key    = "incoming/emails.txt"
  source = "${path.module}/src/emails.txt"
  etag   = filemd5("${path.module}/src/emails.txt")
}

resource "aws_s3_object" "phones" {
  bucket = aws_s3_bucket.sensitive.id
  key    = "incoming/phones.txt"
  source = "${path.module}/src/phones.txt"
  etag   = filemd5("${path.module}/src/phones.txt")
}

resource "aws_s3_object" "ssns" {
  bucket = aws_s3_bucket.sensitive.id
  key    = "incoming/ssns.txt"
  source = "${path.module}/src/ssns.txt"
  etag   = filemd5("${path.module}/src/ssns.txt")
}

resource "aws_s3_object" "credit_cards" {
  bucket = aws_s3_bucket.sensitive.id
  key    = "incoming/credit_cards.txt"
  source = "${path.module}/src/credit_cards.txt"
  etag   = filemd5("${path.module}/src/credit_cards.txt")
}

resource "aws_s3_object" "uuids" {
  bucket = aws_s3_bucket.sensitive.id
  key    = "incoming/uuids.txt"
  source = "${path.module}/src/uuids.txt"
  etag   = filemd5("${path.module}/src/uuids.txt")
}
