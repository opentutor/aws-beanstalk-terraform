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

variable "google_client_id" {
  type        = string
  description = "google client id for google auth (https://developers.google.com/identity/one-tap/web/guides/get-google-api-clientid)"
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