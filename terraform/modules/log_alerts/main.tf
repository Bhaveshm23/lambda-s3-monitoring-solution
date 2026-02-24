#------------------------------------------
# Log Alerts
# Log based metric filters and alarms for specific error pattern 
# For Alerting at the moment
#---------------------------------------------

# Timeout errors
resource "aws_cloudwatch_log_metric_filter" "timeout_errors" {
  name = "${var.function_name}-timeout-errors"
  log_group_name = var.log_group_name
  pattern = "Task timed out"
  metric_transformation {
    name          = "TimeoutErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

#Alarm for timeout errors
resource "aws_cloudwatch_metric_alarm" "timeout_alarm" {
    alarm_name = "${var.function_name}-timeout-errors-alarm"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 1
    metric_name = "TimeoutErrors"
    namespace = var.metric_namespace
    period = 60
    statistic = "Sum"
    threshold = 1
    alarm_description   = "Triggers when Lambda function times out"
    actions_enabled     = true
    alarm_actions       = [var.log_alerts_topic_arn]
    treat_missing_data  = "notBreaching"
}

#Out of memory
resource "aws_cloudwatch_log_metric_filter" "memory_errors" {
  name           = "${var.function_name}-memory-errors"
  log_group_name = var.log_group_name
  pattern        = "?\"MemoryError\" ?\"Runtime exited with error: signal: killed\""

  metric_transformation {
    name          = "MemoryErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Alarm: Memory Errors
resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "${var.function_name}-memory-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryErrors"
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when Lambda runs out of memory"
  actions_enabled     = true
  alarm_actions       = [var.log_alerts_topic_arn]
  treat_missing_data  = "notBreaching"
}


#  Image Processing Errors
resource "aws_cloudwatch_log_metric_filter" "image_processing_errors" {
  name           = "${var.function_name}-image_processing-errors"
  log_group_name = var.log_group_name
  pattern        = "?\"PIL\" ?\"Image processing failed\" ?\"cannot identify image\""

  metric_transformation {
    name          = "ImageProcessingErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Alarm: PIL Errors
resource "aws_cloudwatch_metric_alarm" "image_processing_error_alarm" {
  alarm_name          = "${var.function_name}-image-processing-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ImageProcessingErrors"
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 2
  alarm_description   = "Triggers when image processing fails repeatedly"
  actions_enabled     = true
  alarm_actions       = [var.log_alerts_topic_arn]
  treat_missing_data  = "notBreaching"

}

# S3 Permission Errors
resource "aws_cloudwatch_log_metric_filter" "s3_permission_errors" {
  name           = "${var.function_name}-s3-permission-errors"
  log_group_name = var.log_group_name
  pattern        = "?\"AccessDenied\" ?\"Access Denied\" ?\"403\""

  metric_transformation {
    name          = "S3PermissionErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Alarm: S3 Permission Errors
resource "aws_cloudwatch_metric_alarm" "s3_permission_alarm" {
  alarm_name          = "${var.function_name}-s3-permission-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "S3PermissionErrors"
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when Lambda encounters S3 permission errors"
  actions_enabled     = true
  alarm_actions       = [var.log_alerts_topic_arn]
  treat_missing_data  = "notBreaching"


}

# Critical Application Errors
resource "aws_cloudwatch_log_metric_filter" "critical_errors" {
  name           = "${var.function_name}-critical-errors"
  log_group_name = var.log_group_name
  pattern        = "[timestamp, request_id, level = CRITICAL*, ...]"

  metric_transformation {
    name          = "CriticalErrors"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = "0"
  }
}

# Alarm: Critical Errors
resource "aws_cloudwatch_metric_alarm" "critical_alarm" {
  alarm_name          = "${var.function_name}-critical-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CriticalErrors"
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when CRITICAL level errors are logged"
  actions_enabled     = true
  alarm_actions       = [var.log_alerts_topic_arn]
  treat_missing_data  = "notBreaching"


}