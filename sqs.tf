terraform {
  backend "s3" {
    bucket         = "state-turma-postech-81"    # seu bucket
    key            = "infra-sqs.tfstate"     # caminho do state no S3
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

# DLQ para vídeos que falharam no processamento
resource "aws_sqs_queue" "video_processing_dlq" {
  name                      = "video-processing-dlq"
  message_retention_seconds = 1209600 # 14 dias
  
  tags = {
    Name        = "Video Processing DLQ"
    Environment = var.environment
  }
}

# Fila principal de processamento
resource "aws_sqs_queue" "video_processing" {
  name                       = "video-processing-queue"
  visibility_timeout_seconds = 900 # 15 minutos para processar
  message_retention_seconds  = 345600 # 4 dias
  delay_seconds             = 0
  receive_wait_time_seconds = 20 # Long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.video_processing_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "Video Processing Queue"
    Environment = var.environment
  }
}

# Fila para notificações
resource "aws_sqs_queue" "notifications" {
  name                       = "notifications-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400 # 1 dia
  receive_wait_time_seconds  = 20

  tags = {
    Name        = "Notifications Queue"
    Environment = var.environment
  }
}

# Policy para permitir SNS enviar mensagens para SQS
resource "aws_sqs_queue_policy" "notifications" {
  queue_url = aws_sqs_queue.notifications.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.notifications.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.video_notifications.arn
          }
        }
      }
    ]
  })
}
