resource "aws_ssm_parameter" "notifications_queue_url" {
  name        = "/fiapx/email-notifier/sqs-notifications-queue-url"
  description = "URL da fila SQS de notificações"
  type        = "String"
  value       = aws_sqs_queue.notifications.url

  tags = {
    Name        = "Notifications Queue URL"
    Environment = var.environment
    Service     = "email-notifier"
  }
}

resource "aws_ssm_parameter" "notifications_dlq_url" {
  name        = "/fiapx/email-notifier/sqs-notifications-dlq-url"
  description = "URL da DLQ de notificações"
  type        = "String"
  value       = aws_sqs_queue.notifications_dlq.url

  tags = {
    Name        = "Notifications DLQ URL"
    Environment = var.environment
    Service     = "email-notifier"
  }
}

resource "aws_ssm_parameter" "notifications_queue_arn" {
  name        = "/fiapx/email-notifier/sqs-notifications-queue-arn"
  description = "ARN da fila SQS de notificações"
  type        = "String"
  value       = aws_sqs_queue.notifications.arn

  tags = {
    Name        = "Notifications Queue ARN"
    Environment = var.environment
    Service     = "email-notifier"
  }
}

resource "aws_ssm_parameter" "notifications_dlq_arn" {
  name        = "/fiapx/email-notifier/sqs-notifications-dlq-arn"
  description = "ARN da DLQ de notificações"
  type        = "String"
  value       = aws_sqs_queue.notifications_dlq.arn

  tags = {
    Name        = "Notifications DLQ ARN"
    Environment = var.environment
    Service     = "email-notifier"
  }
}

output "ssm_notifications_queue_url_name" {
  description = "Nome do parâmetro SSM da URL da fila de notificações"
  value       = aws_ssm_parameter.notifications_queue_url.name
}

output "ssm_notifications_dlq_url_name" {
  description = "Nome do parâmetro SSM da URL da DLQ de notificações"
  value       = aws_ssm_parameter.notifications_dlq_url.name
}
