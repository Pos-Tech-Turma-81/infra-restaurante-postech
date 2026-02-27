terraform {
  backend "s3" {
    bucket         = "state-turma-postech-81"    # seu bucket
    key            = "infra-s3.tfstate"     # caminho do state no S3
    region         = "us-east-1"             # região do bucket
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.2"
    }
  }
}

# Bucket para vídeos originais
resource "aws_s3_bucket" "videos_input" {
  bucket = "video-input-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}"

  tags = {
    Name        = "Videos Input Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "videos_input" {
  bucket = aws_s3_bucket.videos_input.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "videos_input" {
  bucket = aws_s3_bucket.videos_input.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Bucket para imagens processadas
resource "aws_s3_bucket" "videos_output" {
  bucket = "video-output-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}"

  tags = {
    Name        = "Videos Output Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "videos_output" {
  bucket = aws_s3_bucket.videos_output.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket para arquivos ZIP
resource "aws_s3_bucket" "videos_zip" {
  bucket = "video-zip-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}"

  tags = {
    Name        = "Videos ZIP Bucket"
    Environment = var.environment
  }
}

# CORS para upload direto
resource "aws_s3_bucket_cors_configuration" "videos_input" {
  bucket = aws_s3_bucket.videos_input.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Block public access - Input
resource "aws_s3_bucket_public_access_block" "videos_input" {
  bucket = aws_s3_bucket.videos_input.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Block public access - Output
resource "aws_s3_bucket_public_access_block" "videos_output" {
  bucket = aws_s3_bucket.videos_output.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Block public access - ZIP
resource "aws_s3_bucket_public_access_block" "videos_zip" {
  bucket = aws_s3_bucket.videos_zip.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

