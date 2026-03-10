# sns.tf
resource "aws_sns_topic" "video_notifications" {
  name = "video-processing-notifications"

  tags = {
    Name        = "Video Processing Notifications"
    Environment = var.environment
  }
}

resource "aws_sns_topic" "video_completed" {
  name = "video-processing-completed"

  tags = {
    Name        = "Video Processing Completed"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "notifications_sqs" {
  topic_arn = aws_sns_topic.video_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.notifications.arn
}


output "video_notifications_topic_arn" {
  description = "ARN do tópico SNS de notificações de vídeo"
  value       = aws_sns_topic.video_notifications.arn
}

output "video_completed_topic_arn" {
  description = "ARN do tópico SNS de vídeos completados"
  value       = aws_sns_topic.video_completed.arn
}
