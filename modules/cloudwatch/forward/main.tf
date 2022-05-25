###
# All infra for shipping cloudwatch logs to an http endpoint (new relic).
# https://docs.newrelic.com/docs/logs/forward-logs/stream-logs-using-kinesis-data-firehose/
# https://aws.amazon.com/blogs/infrastructure-and-automation/how-to-automatically-subscribe-to-amazon-cloudwatch-logs-groups/
# 
###

# resource "random_string" "suffix" {
#   length  = 5
#   special = false
#   upper   = false
# }

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # defined in beanstalk-app
  log_groups = toset([
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/admin-stdout.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/chat-stdout.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/classifier-stdout.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/graphql-stdout.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/home-stdout.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/nginx-access.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/nginx-error.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/nginx-stdout.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/redis-stdout.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/training-stdout.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/upload-api-stdout.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/containers/upload-worker-stdout.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/environment-health.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/var/log/docker-events.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/var/log/eb-activity.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/var/log/eb-ecs-mgr.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/var/log/ecs/ecs-agent.log",
    "/aws/elasticbeanstalk/${var.eb_log_group_prefix}/var/log/ecs/ecs-init.log",
  ])
  lambda_function_name = "${var.name}-log-groups-subscribe"

  lambda_policy_document = {
    sid       = "AllowWriteToCloudwatchLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [replace("${try(aws_cloudwatch_log_group.lambda[0].arn, "")}:*", ":*:*", ":*")]
  }

  lambda_policy_document_subscribe = {
    sid     = "AllowSubscribeCloudwatchLogs"
    effect  = "Allow"
    actions = ["logs:PutSubscriptionFilter"]
    # resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*:*"]
    resources = ["arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*:*"]
  }
}

resource "aws_cloudwatch_event_rule" "log_groups" {
  count = var.enable_auto_subscribe ? 1 : 0

  name        = "${var.name}-capture-new-log-group-created"
  description = "Capture log group creation"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.llogs"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
      "eventSource":[
         "logs.amazonaws.com"
      ],
      "eventName":[
         "CreateLogGroup"
      ]
   }
}
PATTERN

}

resource "aws_cloudwatch_event_target" "log_groups_rule" {
  count     = var.enable_auto_subscribe ? 1 : 0
  rule      = aws_cloudwatch_event_rule.log_groups.name
  target_id = local.lambda_function_name
  arn       = module.lambda.lambda_function_arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  count = var.enable_auto_subscribe ? 1 : 0

  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 90
}

data "aws_iam_policy_document" "lambda" {
  count = var.enable_auto_subscribe ? 1 : 0

  source_policy_documents = [local.lambda_policy_document, local.lambda_policy_document_subscribe]
}


module "lambda" {
  count   = var.enable_auto_subscribe ? 1 : 0
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.27.1"

  function_name = local.lambda_function_name
  description   = "New CloudWatch log group creation handler, subscribes new log groups to a target ARN."

  handler     = "subscribe_group.lambda_handler"
  source_path = "${path.module}/functions/subscribe_group.py"
  runtime     = "python3.8"
  timeout     = 30

  # If publish is disabled, there will be "Error adding new Lambda Permission:
  # InvalidParameterValueException: We currently do not support adding policies for $LATEST."
  publish = true

  environment_variables = {
    LOG_EVENTS = "True" # allow this function to log events for debugging
    TARGET_ARN = aws_kinesis_firehose_delivery_stream.logs_stream.arn
  }

  # Do not use Lambda's policy for cloudwatch logs, because we have to add a policy
  # for KMS conditionally. This way attach_policy_json is always true independenty of
  # the value of presense of KMS. Famous "computed values in count" bug...
  attach_cloudwatch_logs_policy = false
  attach_policy_json            = true
  policy_json                   = try(data.aws_iam_policy_document.lambda[0].json, "")

  use_existing_cloudwatch_log_group = true

  allowed_triggers = {
    AllowExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.log_groups.arn
    }
  }

  store_on_s3 = false

  depends_on = [aws_cloudwatch_log_group.lambda, aws_kinesis_firehose_delivery_stream.logs_stream]
}

resource "aws_s3_bucket" "bucket" {
  bucket = "firehose-cw-failed-${var.name}"
  acl    = "private"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 30
    }
  }
}

resource "aws_kinesis_firehose_delivery_stream" "logs_stream" {
  name        = "kinesis-cw-logs-${var.name}"
  destination = "http_endpoint"

  s3_configuration {
    role_arn           = aws_iam_role.firehose.arn
    bucket_arn         = aws_s3_bucket.bucket.arn
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"
  }

  http_endpoint_configuration {
    url                = var.ingest_url
    name               = var.name
    access_key         = var.api_key
    buffering_size     = 15
    buffering_interval = 600
    role_arn           = aws_iam_role.firehose.arn
    s3_backup_mode     = "FailedDataOnly"

    request_configuration {
      content_encoding = "GZIP"
    }
  }
}

# need a role that grants kinesis required permissions
# https://registry.terraform.io/providers/hashicorp"/aws/latest/docs/resources/kinesis_firehose_delivery_stream#role_arn",
resource "aws_iam_role" "firehose" {
  name = "${var.name}-firehose-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  inline_policy {
    name = "policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
          ],
          "Resource" : [
            "${aws_s3_bucket.bucket.arn}",
            "${aws_s3_bucket.bucket.arn}/*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role" "subscription" {
  name = "${var.name}-cw-subscription"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "logs.${var.aws_region}.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "to_kinesis" {
  role = aws_iam_role.subscription.name

  policy = jsonencode({
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["firehose:*"],
        "Resource" : ["${aws_kinesis_firehose_delivery_stream.logs_stream.arn}"]
      }
    ]
  })
}

# these were created by eb
# resource "aws_cloudwatch_log_group" "cw_log_groups" {
#   for_each          = local.log_groups
#   name              = each.key
#   retention_in_days = 30
# }

# https://github.com/beta-yumatsud/terraform-practice/blob/6536a7f5edfd23f54cbe07da6e8a5317af5d6b76/log.tf
resource "aws_cloudwatch_log_subscription_filter" "cw_subscriptions" {
  count = var.subscribe_existing ? 1 : 0
  
  for_each = local.log_groups

  name            = join("", [reverse(split("/", each.key))[0], "-${var.name}-kinesis-filter"])
  role_arn        = aws_iam_role.subscription.arn
  log_group_name  = each.key
  filter_pattern  = "[]"
  destination_arn = aws_kinesis_firehose_delivery_stream.logs_stream.arn
  depends_on      = [aws_iam_role_policy.to_kinesis, aws_kinesis_firehose_delivery_stream.logs_stream]
}
