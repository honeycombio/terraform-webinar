locals {
  datasets = {
    "cloudwatch-metrics" : "aws-metrics"
  }
}

variable "cloudwatch_granularity" {
  type        = number
  description = "The granularity (in seconds) of the CloudWatch Metrics being published"
  default     = 300
}
