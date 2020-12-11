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

 ## Required Software

 Needs both `terraform` and `terragrunt`. `terragrunt` is a light wrapper over terraform that helps keep terraform DRY, but more importantly for this case, it solves a chicken/egg problem terraform has where you need an s3 state bucket in place to `terraform init`

 On mac and most linux flavors, you can install both terraform and terragrunt with [homebrew](https://brew.sh/), e.g.

 ```
 brew update
 brew install terraform
 brew install terragrunt
 ```

 Or you check [here for other terraform install methods](https://www.terraform.io/downloads.html) and [here for terragrunt install](https://terragrunt.gruntwork.io/docs/getting-started/install/)

