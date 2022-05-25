# This module might be used before or after log groups have been created.
# It's not possible to create a filter for a non-existing log group. 
# This module supports both cases:
# - if the groups already exist (beanstalk up and running), then set `subscribe_existing` to true
# - if they dont exist you can use `enable_auto_subscribe`
# You can use `enable_auto_subscribe` in both cases, it just wont subscribe any existing groups. 

variable "enable_auto_subscribe" {
  type        = bool
  description = "If true it will create a lambda and CW rule to subscribe all newly created groups"
  default     = false
}

variable "subscribe_existing" {
  type        = bool
  description = "Set to true if log groups already exist."
  default     = true
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "name" {
  type        = string
  description = "Project name, e.g. 'v2-mentorpal-new-relic'"
}

variable "eb_log_group_prefix" {
  type        = string
  description = "CW logs are under /aws/elasticbeanstalk/{eb_log_group_prefix}/*, e.g. 'mentorpal-v2-mentorpal'"
}

variable "api_key" {
  type        = string
  description = "http endpoint credentials"
}

variable "ingest_url" {
  type        = string
  description = "HTTP endpoint"
  default     = "https://aws-api.newrelic.com/firehose/v1"
}
