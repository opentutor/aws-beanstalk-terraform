remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket          = "<your_s3_bucket_name, e.g. MY_APP_NAME-s3-state>"
    key             = "opentutor/terraform.tfstate"
    region          = "<your_aws_region, e.g. us-east-1>"
    encrypt         = true
    dynamodb_table  = "<your_lock_table_name, e.g. MY_APP_NAME-s3-state-locks>"
  }
}