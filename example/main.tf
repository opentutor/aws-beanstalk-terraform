module "opentutor_beanstalk_deployment" {
    # really source should be something like
    # the below, swapping "SOME.TAGGED.VERSION" for a real version tag
    # source      = "git::https://github.com/opentutor/terraform-opentutor-aws-beanstalk.git?ref=tags/SOME.TAGGED.VERSION"
    source      = "./.."
    aws_acm_certificate_domain      = var.aws_acm_certificate_domain
    aws_availability_zones          = var.aws_availability_zones
    aws_route53_zone_name           = var.aws_route53_zone_name
    eb_env_env_vars                 = var.eb_env_env_vars
    eb_env_namespace                = var.eb_env_namespace
    eb_env_stage                    = var.eb_env_stage
    region                          = "us-east-1"
}