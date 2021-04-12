provider "aws" {
  region = var.aws_region
}

module "opentutor_beanstalk_deployment" {
    # change the tag below as needed
    # or use source="./.." for local dev
    # MAKE SURE USING LATEST VERSION/TAG IN YOURS
    source      = "git::https://github.com/opentutor/aws-beanstalk-terraform?ref=tags/2.1.0"
    aws_acm_certificate_domain      = var.aws_acm_certificate_domain
    aws_availability_zones          = var.aws_availability_zones
    aws_region                      = var.aws_region
    aws_route53_zone_name           = var.aws_route53_zone_name
    eb_env_env_vars                 = var.eb_env_env_vars
    eb_env_namespace                = var.eb_env_namespace
    eb_env_stage                    = var.eb_env_stage
    eb_env_version_label            = var.eb_env_version_label
    google_client_id                = var.google_client_id
    secret_api_secret                = var.secret_api_secret
    secret_jwt_secret                = var.secret_jwt_secret
    secret_mongo_uri                = var.secret_mongo_uri
    site_domain_name                = var.site_domain_name
    vpc_cidr_block                  = var.vpc_cidr_block
}

variable "aws_acm_certificate_domain" {
  type        = string
  description = "domain name to find ssl certificate"
}

variable "aws_availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_route53_zone_name" {
  type        = string
  description = "name to find aws route53 zone, e.g. opentutor.info."
}

variable "eb_env_env_vars" {
  type        = map(string)
  default     = {}
  description = "Map of custom ENV variables to be provided to the application running on Elastic Beanstalk, e.g. env_vars = { DB_USER = 'admin' DB_PASS = 'xxxxxx' }"
}

variable "eb_env_namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "eb_env_stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  default     = "test"
}

variable "eb_env_version_label" {
  type        = string
  description = "generally leave this blank, unless you're trying to force a different app version along with infra updates"
  default     = ""
}

variable "google_client_id" {
  type        = string
  description = "google client id for google auth (https://developers.google.com/identity/one-tap/web/guides/get-google-api-clientid)"
}

variable "secret_api_secret" {
  type        = string
  description = "an arbitrary secret shared among services to allow admin access in inter-service graphql requests"
}

variable "secret_jwt_secret" {
  type        = string
  description = "an arbitrary secret shared among services to encode/decode jwt tokens"
}

variable "secret_mongo_uri" {
  type        = string
  description = "fully qualified mongo uri (includes user and password) for connections to a mongodb instance backend (presumably external, e.g. mongodb.com)"
}

variable "site_domain_name" {
  type        = string
  description = "the public domain name for this site, e.g. opentutor.yoursite.org"
}

variable "vpc_cidr_block" {
  type        = string
  description = "cidr for the vpc, generally can leave the default unless there is conflict"
  default     = "10.7.0.0/16"
}

output "efs_file_system_id" {
  description = "id for the efs file system (use to mount from beanstalk)"
  value       = module.opentutor_beanstalk_deployment.efs_file_system_id
}