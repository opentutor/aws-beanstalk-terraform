remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # name for an s3 bucket that will store terraform state
    # e.g. MY_APP_NAME-s3-state
    # terragrunt will create this for us
    bucket          = "<your_s3_bucket_name>"

    # probably can leave this as is
    key             = "opentutor/terraform.tfstate"

    # your AWS_REGION e.g. us-east-1 
    # (generally should be same as one for app)
    region          = "<your_aws_region>"

    # leave this on
    encrypt         = true

    # name of the AWS dynamodb table used for locking state
    # e.g. MY_APP_NAME-s3-state-locks
    # terragrunt will create this for us
    dynamodb_table  = "<your_lock_table_name>"
  }
}