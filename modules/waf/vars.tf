variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "rate_limit" {
  type    = number
  default = 100 # minimum
}
