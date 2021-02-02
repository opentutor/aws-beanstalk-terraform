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

variable "eb_env_additional_settings" {
  type = list(object({
    namespace = string
    name      = string
    value     = string
  }))

  description = "Additional Elastic Beanstalk setttings. For full list of options, see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html"
  default     = [
      {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name      = "StickinessEnabled"
        value     = "false"
      },
      {
        namespace = "aws:elasticbeanstalk:managedactions"
        name      = "ManagedActionsEnabled"
        value     = "false"
      }
  ]
}

variable "eb_env_application_port" {
  type        = number
  description = "Port application is listening on"
  default     = 80
}

variable "eb_env_attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "eb_env_autoscale_lower_bound" {
  type        = number
  description = "Minimum level of autoscale metric to remove an instance"
  default     = 20
}

variable "eb_env_autoscale_lower_increment" {
  type        = number
  description = "How many Amazon EC2 instances to remove when performing a scaling activity."
  default     = -1
}

variable "eb_env_autoscale_max" {
  type        = number
  description = "Maximum instances to launch"
  default     = 1
}

variable "eb_env_autoscale_min" {
  type        = number
  description = "Minumum instances to launch"
  default     = 1
}

variable "eb_env_autoscale_measure_name" {
  type        = string
  description = "Metric used for your Auto Scaling trigger"
  default     = "CPUUtilization"
}

variable "eb_env_autoscale_statistic" {
  type        = string
  description = "Statistic the trigger should use, such as Average"
  default     = "Average"
}

variable "eb_env_autoscale_unit" {
  type        = string
  description = "Unit for the trigger measurement, such as Bytes"
  default     = "Percent"
}

variable "eb_env_autoscale_upper_bound" {
  type        = number
  description = "Maximum level of autoscale metric to add an instance"
  default     = 80
}

variable "eb_env_autoscale_upper_increment" {
  type        = number
  description = "How many Amazon EC2 instances to add when performing a scaling activity"
  default     = 1
}

variable "eb_env_availability_zone_selector" {
  type        = string
  description = "Availability Zone selector"
  default     = "Any 2"
}

variable "eb_env_delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "eb_env_description" {
  type        = string
  description = "Short description of the Environment"
  default     = "Opentutor Elastic Beanstalk env"
}

variable "eb_env_elb_scheme" {
  type        = string
  description = "Specify `internal` if you want to create an internal load balancer in your Amazon VPC so that your Elastic Beanstalk application cannot be accessed from outside your Amazon VPC"
  default     = "public"
}

variable "eb_env_environment_type" {
  type        = string
  description = "Environment type, e.g. 'LoadBalanced' or 'SingleInstance'.  If setting to 'SingleInstance', `rolling_update_type` must be set to 'Time', `updating_min_in_service` must be set to 0, and `loadbalancer_subnets` will be unused (it applies to the ELB, which does not exist in SingleInstance environments)"
  default     = "LoadBalanced"
}

variable "eb_env_env_vars" {
  type        = map(string)
  default     = {}
  description = "Map of custom ENV variables to be provided to the application running on Elastic Beanstalk, e.g. env_vars = { DB_USER = 'admin' DB_PASS = 'xxxxxx' }"
}

variable "eb_env_healthcheck_url" {
  type        = string
  description = "Application Health Check URL. Elastic Beanstalk will call this URL to check the health of the application running on EC2 instances"
  default     = "/" 
}

variable "eb_env_instance_type" {
  type        = string
  description = "Instances type"
  default     = "t3.xlarge"  # between all the microservices needs at least 16GB memory
}

variable "eb_env_keypair" {
  type        = string
  description = "key pair for ssh access (only for debugging and/or when application is in public subnet)"
  default     = ""
}

variable "eb_env_loadbalancer_ssl_policy" {
  type        = string
  description = "ssl policy for load balancer"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "eb_env_loadbalancer_type" {
  type        = string
  description = "Load Balancer type, e.g. 'application' or 'classic'"
  default     = "application"
}

variable "eb_env_log_bucket_force_destroy" {
  type        = bool
  description = "Force destroy the S3 bucket for load balancer logs"
  default     = true
}

variable "eb_env_name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'cluster'"
  default     = "opentutor"
}

variable "eb_env_namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "eb_env_rolling_update_enabled" {
  type        = bool
  description = "Whether to enable rolling update"
  default     = false
}

variable "eb_env_rolling_update_type" {
  type        = string
  description = "`Health` or `Immutable`. Set it to `Immutable` to apply the configuration change to a fresh group of instances"
  default     = "Health"
}

variable "eb_env_root_volume_size" {
  type        = number
  description = "The size of the EBS root volume"
  default     = 8
}

variable "eb_env_root_volume_type" {
  type        = string
  description = "The type of the EBS root volume"
  default     = "gp2"
}

variable "eb_env_stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  default     = "test"
}

variable "eb_env_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "eb_env_version_label" {
  type        = string
  description = "Elastic Beanstalk Application version to deploy"
  default     = ""
}

variable "eb_env_wait_for_ready_timeout" {
  type        = string
  description = "The maximum duration to wait for the Elastic Beanstalk Environment to be in a ready state before timing out"
  default     = "30m"
}

variable "eb_env_updating_max_batch" {
  type        = number
  description = "Maximum number of instances to update at once"
  default     = 1
}

variable "eb_env_updating_min_in_service" {
  type        = number
  description = "Minimum number of instances in service during update"
  default     = 1
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
