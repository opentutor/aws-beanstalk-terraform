# terraform-opentutor-aws-beanstalk

Terraform module creates infrastructure for an opentutor Elastic Beanstalk deployment on AWS

TODO:

 - [x] creates/destroys beanstalk infra that runs app
 - [ ] ensure all features working (home page)
 - [ ] ensure all features working (online training)
 - [x] stores tf state in an S3 bucket
 - [x] configurable for CNAME, e.g. opentutor.org
 - [x] SSL support (https://opentutor.org)
 - [ ] instances use shared EFS mount for online-trained models
 - [ ] functions as a terraform module, where actual deployments just include the module