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
    bucket          = "opentutor-dev-s3-state"

    # probably can leave this as is
    key             = "opentutor/terraform.tfstate"

    # your AWS_REGION e.g. us-east-1 
    # (generally should be same as one for app)
    region          = "us-west-1"

    # leave this on
    encrypt         = true

    # name of the AWS dynamodb table used for locking state
    # e.g. MY_APP_NAME-s3-state-locks
    # terragrunt will create this for us
    dynamodb_table  = "opentutor-dev-s3-state-locks"
  }
}