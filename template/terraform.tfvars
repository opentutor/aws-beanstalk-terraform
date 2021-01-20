# e.g. 'opentutor.info' (must be in AWS certificate manager)>
aws_acm_certificate_domain = "<domain name of your site>"

# e.g. us-east-1
aws_region = "<AWS REGION>"

# usualy name as `aws_acm_certificate_domain` with . at the end
aws_route53_zone_name = "<e.g. opentutor.info.>"

# usually just `a` and `b` for your AWS_REGION, e.g. ["us-east-1a", "us-east-1b"]
aws_availability_zones = ["<a>", "<b>"]

# namespace to prefix all things your app
eb_env_namespace = "<a namespace>"

# name of stage, e.g 'test' or 'dev' or 'prod'
eb_env_stage = "<stage name>"

# the non-secret google client id that configure google auth
# https://developers.google.com/identity/one-tap/web/guides/get-google-api-clientid
google_client_id = "<your client id>"
