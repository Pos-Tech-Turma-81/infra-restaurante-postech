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

# DLQ para notificações
resource "aws_sqs_queue" "notifications_dlq" {
  name                      = "notifications-dlq"
  message_retention_seconds = 1209600 # 14 dias

  tags = {
    Name        = "Notifications DLQ"
    Environment = var.environment
  }
}

# Fila para notificações
resource "aws_sqs_queue" "notifications" {
  name                       = "notifications-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400 # 1 dia
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notifications_dlq.arn
    maxReceiveCount     = 5
  })

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


output "video_processing_queue_url" {
  description = "URL da fila de processamento de vídeos"
  value       = aws_sqs_queue.video_processing.url
}

output "video_processing_queue_arn" {
  description = "ARN da fila de processamento de vídeos"
  value       = aws_sqs_queue.video_processing.arn
}

output "video_processing_dlq_url" {
  description = "URL da DLQ de processamento de vídeos"
  value       = aws_sqs_queue.video_processing_dlq.url
}

output "video_processing_dlq_arn" {
  description = "ARN da DLQ de processamento de vídeos"
  value       = aws_sqs_queue.video_processing_dlq.arn
}

output "notifications_queue_url" {
  description = "URL da fila de notificações (para email-notifier)"
  value       = aws_sqs_queue.notifications.url
}

output "notifications_queue_arn" {
  description = "ARN da fila de notificações"
  value       = aws_sqs_queue.notifications.arn
}

output "notifications_dlq_url" {
  description = "URL da DLQ de notificações"
  value       = aws_sqs_queue.notifications_dlq.url
}

output "notifications_dlq_arn" {
  description = "ARN da DLQ de notificações"
  value       = aws_sqs_queue.notifications_dlq.arn
}
