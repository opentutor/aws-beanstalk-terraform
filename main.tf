provider "aws" {
  region  = var.region
  profile = "opentutor"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.16.1"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = var.attributes
  tags       = var.tags
  delimiter  = var.delimiter
  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.26.0"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  attributes           = var.attributes
  tags                 = var.tags
  delimiter            = var.delimiter
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = true
  nat_instance_enabled = false
}

module "elastic_beanstalk_application" {
  source      = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=tags/0.7.1"
  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  tags        = var.tags
  delimiter   = var.delimiter
  description = "Test elastic_beanstalk_application"
}

data "aws_elastic_beanstalk_hosted_zone" "current" {}

module "elastic_beanstalk_environment" {
  source                     = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=tags/0.31.0"
  namespace                  = var.namespace
  stage                      = var.stage
  name                       = var.name
  attributes                 = var.attributes
  tags                       = var.tags
  delimiter                  = var.delimiter
  description                = var.description
  region                     = var.region
  availability_zone_selector = var.availability_zone_selector
  # NOTE: We would prefer for the DNS name 
  # of module.elastic_beanstalk_environment
  # to be staticly set via inputs,
  # but have been running into other/different problems
  # trying to get that to work 
  # (for one thing, permissions error anytime try to set
  # elastic_beanstalk_environment.dns_zone_id)
  # dns_zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
  # dns_zone_id                = var.dns_zone_id
  wait_for_ready_timeout             = var.wait_for_ready_timeout
  elastic_beanstalk_application_name = module.elastic_beanstalk_application.elastic_beanstalk_application_name
  environment_type                   = var.environment_type
  loadbalancer_type                  = var.loadbalancer_type
  loadbalancer_certificate_arn       = data.aws_acm_certificate.issued.arn
  loadbalancer_ssl_policy            = "ELBSecurityPolicy-TLS-1-2-2017-01"
  elb_scheme                         = var.elb_scheme
  tier                               = var.tier
  version_label                      = var.version_label
  force_destroy                      = var.force_destroy

  instance_type    = var.instance_type
  root_volume_size = var.root_volume_size
  root_volume_type = var.root_volume_type

  autoscale_min             = var.autoscale_min
  autoscale_max             = var.autoscale_max
  autoscale_measure_name    = var.autoscale_measure_name
  autoscale_statistic       = var.autoscale_statistic
  autoscale_unit            = var.autoscale_unit
  autoscale_lower_bound     = var.autoscale_lower_bound
  autoscale_lower_increment = var.autoscale_lower_increment
  autoscale_upper_bound     = var.autoscale_upper_bound
  autoscale_upper_increment = var.autoscale_upper_increment

  vpc_id                  = module.vpc.vpc_id
  loadbalancer_subnets    = module.subnets.public_subnet_ids
  # TODO change subnets for efs back to private after debugging
  // application_subnets     = module.subnets.public_subnet_ids
  application_subnets     = module.subnets.private_subnet_ids
  allowed_security_groups = [module.vpc.vpc_default_security_group_id]
  # NOTE: will only work for direct ssh
  # if keypair exists and application_subnets above is public subnet
  keypair                 = var.elastic_beanstalk_environment_keypair     

  rolling_update_enabled  = var.rolling_update_enabled
  rolling_update_type     = var.rolling_update_type
  updating_min_in_service = var.updating_min_in_service
  updating_max_batch      = var.updating_max_batch

  healthcheck_url  = var.healthcheck_url
  application_port = var.application_port

  // https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html
  // https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html#platforms-supported.docker
  solution_stack_name = var.solution_stack_name

  additional_settings = var.additional_settings
  env_vars            = var.env_vars

  extended_ec2_policy_document = data.aws_iam_policy_document.minimal_s3_permissions.json
  prefer_legacy_ssm_policy     = false
}

data "aws_iam_policy_document" "minimal_s3_permissions" {
  statement {
    sid = "AllowS3OperationsOnElasticBeanstalkBuckets"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }
}

# public cname/alias for the site
# pull in the dns zone
data "aws_route53_zone" "site_dns" {
  name = var.aws_route53_zone_name
}

# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  domain   = var.aws_acm_certificate_domain
  statuses = ["ISSUED"]
}


# create dns record of type "A"
resource "aws_route53_record" "site_alias" {
  zone_id         = data.aws_route53_zone.site_dns.zone_id
  name            = data.aws_route53_zone.site_dns.name
  type            = "A"
  allow_overwrite = true
  # create alias (required: name, zone_id)
  alias {
    name                   = module.elastic_beanstalk_environment.endpoint
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}

module "efs" {
  source             = "git::https://github.com/cloudposse/terraform-aws-efs.git?ref=tags/0.22.0"
  namespace          = var.namespace
  stage              = var.stage
  name               = var.name
  region             = var.region
  vpc_id             = module.vpc.vpc_id
  # TODO change subnets for efs back to private after debugging
  // subnets            = module.subnets.public_subnet_ids
  subnets            = module.subnets.private_subnet_ids
  security_groups    = [module.vpc.vpc_default_security_group_id]
  // zone_id            = data.aws_elastic_beanstalk_hosted_zone.current.id
  // context = module.this.context
}