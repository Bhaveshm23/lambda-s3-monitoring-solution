output "critical_alerts_topic_arn" {
  description = "ARN of the critical alerts SNS topic"
  value       = aws_sns_topic.sns_critical_alerts.arn
}

output "performance_alerts_topic_arn" {
  description = "ARN of the performance alerts SNS topic"
  value       = aws_sns_topic.sns_performance_alerts.arn
}

output "log_alerts_topic_arn" {
  description = "ARN of the log alerts SNS topic"
  value       = aws_sns_topic.sns_log_alerts.arn
}

output "critical_alerts_topic_name" {
  description = "Name of the critical alerts SNS topic"
  value       = aws_sns_topic.sns_critical_alerts.name
}

output "performance_alerts_topic_name" {
  description = "Name of the performance alerts SNS topic"
  value       = aws_sns_topic.sns_performance_alerts.name
}

output "log_alerts_topic_name" {
  description = "Name of the log alerts SNS topic"
  value       = aws_sns_topic.sns_log_alerts.name
}