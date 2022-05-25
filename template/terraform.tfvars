# e.g. 'opentutor.info' (must be in AWS certificate manager)>
aws_acm_certificate_domain = "opentutor.info"

# e.g. us-east-1
aws_region = "us-east-1"

# usualy name as `aws_acm_certificate_domain` with . at the end
aws_route53_zone_name = "opentutor.info."

# usually just `a` and `b` for your AWS_REGION, e.g. ["us-east-1a", "us-east-1b"]
aws_availability_zones = ["us-east-1a", "us-east-1b"]

# namespace to prefix all things your app
eb_env_namespace = "temp"

# name of stage, e.g 'test' or 'dev' or 'prod'
eb_env_stage = "dev"

# the non-secret google client id that configure google auth
# https://developers.google.com/identity/one-tap/web/guides/get-google-api-clientid
google_client_id = "1032888344124-aim2fdal2cfvqf290tullhs1rt9rahvu.apps.googleusercontent.com"

# public domain name of site, e.g. opentutor.yourdomain.com
site_domain_name = "dev.opentutor.info"