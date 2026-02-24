#---------------------------
# Cloudwatch metrices module
# To collect metrices overtime : Observability
#---------------------------

#Metric Filter for Lambda errors : keep track of error count follows pattern matching
resource "aws_cloudwatch_log_metric_filter" "lambda_errors" {
  name = "${var.function_name}-error-count" 
  log_group_name = var.log_group_name

  # first field : timestamp, second field: req id, third field: Errror followed by something
  pattern = "[timestamp, request_id, level = ERROR*, ...]" # example: 2026-01-22T10:15:30Z 1234-abc ERROR Something went wrong 

 # Metric filters convert matching log entries into numeric CloudWatch metrics so that alarms and dashboards can be created on application behavior.
  metric_transformation {
    name = "Lambda Errors"
    namespace = var.metric_namespace # group metric by namespace
    value = "1" # everytime a log line matches the pattern emit value 1, so 1 error = 1, 5 errors = 5 ie count errors
    default_value = "0" # if no match occurs then value should be 0
  }
}

#Metric Filer for image processing time
#This metric filter reads processing time from Lambda logs and publishes it as a CloudWatch metric in milliseconds to monitor the performance
resource "aws_cloudwatch_log_metric_filter" "processing_time" {
  name = "${var.function_name}-processing-time"
  log_group_name = var.log_group_name

  #Example: 2026-01-22T10:15:30Z abc-123 INFO Image processed processing_time: 245
  pattern = "[timestamp, request_id, level, message, processing_time_key = \"processing_time:\", processing_time, ...]" 

  metric_transformation {
    name = "ImageProcessingTime"
    namespace = var.metric_namespace
    value = "$processing_time" # value captured from the above pattern ie 245 in example
    unit = "Milliseconds"
    default_value = "0"
  }
}

#Metric filter for successful process
resource "aws_cloudwatch_log_metric_filter" "successful_processes" {
    name = "${var.function_name}-success-count"
    log_group_name = var.log_group_name
    pattern = "\"Successfully processed\""
    
    metric_transformation {
      name = "SuccessfulProcesses"
      namespace = var.metric_namespace
      value = "1"
      default_value = "0"
    } 
}

#Metric filter for Image Size
resource "aws_cloudwatch_log_metric_filter" "image_size" {
    name = "${var.function_name}-image-size"
    log_group_name = var.log_group_name
    pattern = "[timestamp, request_id, level, message, size_key = \"image_size:\", image_size, ...]"
    
    metric_transformation {
      name = "ImageSizeBytes"
      namespace = var.metric_namespace
      value = "$image_size"
      unit = "Bytes"
      default_value = "0"
    } 
}

#Creating a cloud watch dashboard
resource "aws_cloudwatch_dashboard" "lambda_monitoring" {
  count          = var.enable_dashboard ? 1 : 0 # set when we have differnt envs, like want dashboard on PRD and not on DEV
  dashboard_name = "${var.function_name}-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum", label = "Total Invocations" }],
            [".", "Errors", { stat = "Sum", label = "Errors" }], # '.' -> same namespcae as above ones
            [".", "Throttles", { stat = "Sum", label = "Throttles" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Lambda Invocations & Errors"
          period  = 300
          dimensions = {
            FunctionName = var.function_name
          }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 0
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", { stat = "Average", label = "Avg Duration" }],
            ["...", { stat = "Maximum", label = "Max Duration" }],
            ["...", { stat = "p99", label = "P99 Duration" }] # isualizes system performance, focusing on the 99th percentile of metrics (like latency), showing how the slowest 1% of requests or operations perform
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Lambda Duration (ms)"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
          dimensions = {
            FunctionName = var.function_name
          }
        }
        width  = 12
        height = 6
        x      = 12
        y      = 0
      },
      {
        ##Peak concurrent Lambda executions in a 5-minute window
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "ConcurrentExecutions", { stat = "Maximum", label = "Concurrent Executions" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Concurrent Executions"
          period  = 300
          dimensions = {
            FunctionName = var.function_name
          }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 6
      },
      {
        type = "metric"
        properties = {
          metrics = [
            [var.metric_namespace, "LambdaErrors", { stat = "Sum", label = "Log Errors" }],
            [".", "SuccessfulProcesses", { stat = "Sum", label = "Successful" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Custom Metrics: Errors vs Success"
          period  = 300
        }
        width  = 12
        height = 6
        x      = 12
        y      = 6
      },
      {
        type = "metric"
        properties = {
          metrics = [
            [var.metric_namespace, "ImageProcessingTime", { stat = "Average", label = "Avg Processing Time" }],
            ["...", { stat = "Maximum", label = "Max Processing Time" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Image Processing Time (ms)"
          period  = 300
        }
        width  = 12
        height = 6
        x      = 0
        y      = 12
      },
      {
        type = "metric"
        properties = {
          metrics = [
            [var.metric_namespace, "ImageSizeBytes", { stat = "Average", label = "Avg Image Size" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Image Size (Bytes)"
          period  = 300
        }
        width  = 12
        height = 6
        x      = 12
        y      = 12
      },
      {
        #Gives recent errors
        type = "log"
        properties = {
          query  = "SOURCE '${var.log_group_name}'\n| fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20"
          region = var.aws_region
          title  = "Recent Errors"
        }
        width  = 24
        height = 6
        x      = 0
        y      = 18
      }
    ]
  })
}