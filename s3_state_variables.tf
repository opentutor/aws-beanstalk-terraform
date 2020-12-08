# variable "region" {
#   type        = string
#   description = "AWS region"
# }

variable "s3_state_bucket_name" {
  type        = string
  description = "s3 bucket used to store shared/versioned tf state for this deployment"
}
