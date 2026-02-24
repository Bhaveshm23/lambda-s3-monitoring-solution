#-----------------------
# SNS Notification Module
# Create differnt types of SNS topics for differnt alert types
#------------------------

#SNS for Critical Alerts(Errors, Failures)
resource "aws_sns_topic" "sns_critical_alerts" {
  name = "${var.project_name}-critical-alerts"
  display_name = "Critical Lambda Alerts"

  tags = {
    Name = "${var.project_name}-critical-alerts"
    AlertType = "Critical"
  }
}



#SNS for Performance Alerts(Duration, Memory)
resource "aws_sns_topic" "sns_performance_alerts" {
  name = "${var.project_name}-performance-alerts"
  display_name = "Performance Lambda Alerts"

   tags = {
    Name = "${var.project_name}-performance-alerts"
    AlertType = "Performance"
  } 
}


#SNS for Log based Alerts
resource "aws_sns_topic" "sns_log_alerts" {
  name = "${var.project_name}-log-alerts"
  display_name = "Log Lambda Alerts"

   tags = {
    Name = "${var.project_name}-log-alerts"
    AlertType = "Logs"
  } 
}

###Email Subsctiptions

#Critical Alerts
resource "aws_sns_topic_subscription" "critical_email" {
  count = var.critical_alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.sns_critical_alerts.arn
  protocol = "email"
  endpoint = var.critical_alert_email
}


#Performance Alerts
resource "aws_sns_topic_subscription" "performance_email" {
  count = var.performance_alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.sns_performance_alerts.arn
  protocol = "email"
  endpoint = var.performance_alert_email
}


#Log Alerts
resource "aws_sns_topic_subscription" "log_email" {
  count = var.log_alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.sns_log_alerts.arn
  protocol = "email"
  endpoint = var.log_alert_email
}

#SNS Topic Policy for CloudWatch to publish logs
resource "aws_sns_topic_policy" "critical_alerts_policy" {
  arn = aws_sns_topic.sns_critical_alerts.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.sns_critical_alerts.arn
      }
    ]
  })
}

resource "aws_sns_topic_policy" "performance_alerts_policy" {
 arn = aws_sns_topic.sns_performance_alerts.arn
 policy =  jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.sns_performance_alerts.arn
      }
    ]
  })
}

resource "aws_sns_topic_policy" "log_alerts_policy" {
  arn = aws_sns_topic.sns_log_alerts.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.sns_log_alerts.arn
      }
    ]
  })
}