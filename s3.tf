# Bucket único para todo o fluxo de vídeos
resource "aws_s3_bucket" "videos" {
  bucket = var.bucket_name

  tags = {
    Name        = "Videos Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "videos" {
  bucket = aws_s3_bucket.videos.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "videos" {
  bucket = aws_s3_bucket.videos.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# CORS para upload direto (se precisar)
resource "aws_s3_bucket_cors_configuration" "videos" {
  bucket = aws_s3_bucket.videos.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Block public access - Bucket
resource "aws_s3_bucket_public_access_block" "videos" {
  bucket = aws_s3_bucket.videos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Opcional: criar objetos vazios para “pastas” lógicas
resource "aws_s3_object" "folder_processar" {
  bucket = aws_s3_bucket.videos.id
  key    = "processar/"
}

resource "aws_s3_object" "folder_processando" {
  bucket = aws_s3_bucket.videos.id
  key    = "processando/"
}

resource "aws_s3_object" "folder_processado" {
  bucket = aws_s3_bucket.videos.id
  key    = "processado/"
}
