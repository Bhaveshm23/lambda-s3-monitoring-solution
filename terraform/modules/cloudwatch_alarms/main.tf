#------------------------------
# Cloud Watch Alarms
#------------------------------

#Alarm for lambda error rates
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
    alarm_name = "${var.function_name}-high-error-rate"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = var.error_evaluation_periods
    metric_name = "Errors"
    namespace = var.alarm_namespace
    period = var.alarm_period
    statistic = "Sum"
    threshold = var.error_threshold
    alarm_description = "Triggers when Lambda function has more than ${var.error_threshold} errors"
    actions_enabled = true
    alarm_actions = [var.critical_alerts_topic_arn] #sns topic arn
    ok_actions = [var.critical_alerts_topic_arn]

    dimensions = {
      FunctionName = var.function_name
    } 
}

# Alarm for duration for which lambda function runs (Timeout warning)
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name = "${var.function_name}-high-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = var.duration_evaluation_periods
  metric_name = "Duration"
  namespace = var.alarm_namespace
  period = var.alarm_period
  statistic = "Average"
  threshold = var.duration_threshold_ms
  alarm_description = "Triggers when Lambda duration exceeds ${var.duration_threshold_ms}ms (approaching timeout)"
  actions_enabled = true
  alarm_actions = [var.performance_alerts_topic_arn]
  ok_actions = [var.performance_alerts_topic_arn]
  dimensions = {
    FunctionName = var.function_name
  }
}

#Alarm for lamba throttles
#Lambda throttling occurs when AWS rejects invocation requests because the number of concurrent Lambda executions 
#exceeds the allowed limit, meaning the function never starts executing.

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${var.function_name}-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.throttle_evaluation_periods
  metric_name         = "Throttles"
  namespace           = var.alarm_namespace
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.throttle_threshold
  alarm_description   = "Triggers when Lambda function is throttled (concurrent execution limit reached)"
  actions_enabled     = true
  alarm_actions       = [var.critical_alerts_topic_arn]
  ok_actions          = [var.critical_alerts_topic_arn]

  dimensions = {
    FunctionName = var.function_name
  }
  
}

# Alarm for concurrent executions
resource "aws_cloudwatch_metric_alarm" "concurrent_executions" {
  alarm_name          = "${var.function_name}-high-concurrency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ConcurrentExecutions"
  namespace           = var.alarm_namespace
  period              = var.alarm_period
  statistic           = "Maximum"
  threshold           = var.concurrent_executions_threshold
  alarm_description   = "Triggers when concurrent executions exceed ${var.concurrent_executions_threshold}"
  actions_enabled     = true
  alarm_actions       = [var.performance_alerts_topic_arn]

  dimensions = {
    FunctionName = var.function_name
  }
}

# Alarm for custom error from logs
resource "aws_cloudwatch_metric_alarm" "log_errors" {
  alarm_name          = "${var.function_name}-log-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "LambdaErrors"
  namespace           = var.metric_namespace
  period              = 60
  statistic           = "Sum"
  threshold           = var.log_error_threshold
  alarm_description   = "Triggers when ERROR logs are detected in Lambda function"
  actions_enabled     = true
  alarm_actions       = [var.critical_alerts_topic_arn]
  treat_missing_data  = "notBreaching" #If lambda doesn't run, it won't produce any data. Treat no data as not breaching. This will avoid false alarms

}


# Alarm for Successful Processes (Business Metric)
resource "aws_cloudwatch_metric_alarm" "low_success_rate" {
  alarm_name          = "${var.function_name}-low-success-rate"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "SuccessfulProcesses"
  namespace           = var.metric_namespace
  period              = 300
  statistic           = "Sum"
  threshold           = var.min_success_threshold
  alarm_description   = "Triggers when successful image processes are below expected rate"
  actions_enabled     = true
  alarm_actions       = [var.performance_alerts_topic_arn]
  treat_missing_data  = "notBreaching"

}