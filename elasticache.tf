terraform {
  backend "s3" {
    bucket         = "state-turma-postech-81"    # seu bucket
    key            = "infra-elasticache.tfstate"     # caminho do state no S3
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

# Security Group para Redis
resource "aws_security_group" "redis" {
  name        = "redis-cache-sg"
  description = "Security group for Redis ElastiCache"
  vpc_id      = local.vpc_id

  ingress {
    description = "Redis from EKS"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Redis Cache SG"
    Environment = var.environment
  }
}

# Subnet group para Redis
resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-subnet-group"
  subnet_ids = local.private_subnets

  tags = {
    Name        = "Redis Subnet Group"
    Environment = var.environment
  }
}

# Redis cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "video-cache"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  tags = {
    Name        = "Video Processing Cache"
    Environment = var.environment
  }
}
