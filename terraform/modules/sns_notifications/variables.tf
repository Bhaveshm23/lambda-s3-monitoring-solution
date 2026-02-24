variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "critical_alert_email" {
  description = "Email address for critical alerts (errors, failures)"
  type        = string
  default     = ""
}

variable "performance_alert_email" {
  description = "Email address for performance alerts (duration, memory)"
  type        = string
  default     = ""
}

variable "log_alert_email" {
  description = "Email address for log-based alerts"
  type        = string
  default     = ""
}
