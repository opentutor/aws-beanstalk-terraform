# we want terraform-opentutor-aws-beanstalk
# to become an reusable module,
# so it shouldn't bundle in the state management
# which belongs instead with the deployment
# (unless we can bundle it and make it conditional)

# provider "aws" {
#   region = var.region
# }

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_state_bucket_name
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.s3_state_bucket_name}-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  # unfortunately, vars not allowed in terraform blocks...
  backend "s3" {
    bucket         = "opentutor-s3-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "opentutor-s3-state-locks"
    encrypt        = true
  }
}
