resource "aws_wafv2_web_acl" "wafv2_webacl" {
  name  = "mentorpal-${var.environment}-wafv2-webacl"
  scope = "CLOUDFRONT"
  tags  = var.tags

  default_action {
    allow {}
  }

  rule {
    name     = "ip-rate-limit-rule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = var.rate_limit
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.rate_limit}-ip-rate-limit-rule"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "common-control"
    priority = 2

    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        # see https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html#aws-managed-rule-groups-baseline-crs
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        excluded_rule {
          # 8kb is not enough to post videos
          name = "SizeRestrictions_BODY"
        }
        excluded_rule {
          # flags legit thumbnail upload attemts
          name = "CrossSiteScripting_BODY"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-Common-rule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "bot-control"
    priority = 3

    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        # see https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-bot.html
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
        
        excluded_rule {
          name = "CategorySocialMedia" # slack
        }
        excluded_rule {
          name = "CategorySearchEngine" # google bot
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-BotControl-rule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 4
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      metric_name                = "AWS-Linux-rule"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "mentorpal-${var.environment}-wafv2-webacl"
    sampled_requests_enabled   = true
  }
}

resource "aws_s3_bucket" "s3_logs" {
  bucket = "mentorpal-aws-waf-logs-${var.aws_region}-${var.environment}"
  acl    = "private"
  tags   = var.tags
}

data "aws_iam_policy_document" "policy_assume_kinesis" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "mentorpal-firehose-aws-waf-logs-${var.aws_region}-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_kinesis.json
  tags               = var.tags
}

# https://docs.aws.amazon.com/firehose/latest/dev/controlling-access.html#using-iam-s3
data "aws_iam_policy_document" "s3_policy_document" {
  statement {
    sid = "1"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]

    resources = [
      aws_s3_bucket.s3_logs.arn,
    ]
  }

  statement {
    sid = "2"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.s3_logs.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name   = "mentorpal-kinesis-s3-write-policy-${var.environment}"
  policy = data.aws_iam_policy_document.s3_policy_document.json
}

resource "aws_iam_role_policy_attachment" "firehose_s3_policy_attachment" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_kinesis_firehose_delivery_stream" "waf_logs_kinesis_stream" {
  # the name must begin with aws-waf-logs-
  name        = "aws-waf-logs-kinesis-stream-mentorpal-${var.environment}"
  destination = "s3"
  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.s3_logs.arn
    compression_format = "GZIP"
  }
  tags = var.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging_conf_staging" {
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs_kinesis_stream.arn]
  resource_arn            = aws_wafv2_web_acl.wafv2_webacl.arn
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}

output "wafv2_webacl_arn" {
  value = aws_wafv2_web_acl.wafv2_webacl.arn
}
