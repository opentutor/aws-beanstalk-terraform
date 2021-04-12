# Terraform Template for a new Opentutor site on AWS Elastic Beanstalk

This is a template for the terraform to set up your site's "Opentutor on AWS Elastic Beanstalk" infrastructure. The basic idea is that you can copy the contents of this template folder, edit a few values and then use to `terraform`/`terragrunt` to deploy the infrastructure.

## Roles and permissions

A central intention of this setup is to allow developers to define the infrastructure for an Opentutor deployment even though they may not have permissions in AWS to execute the deployment.

In practice, these two roles may be assumed by a single person, but will try to distinguish instructions as to whether to one or the other for cases where it really is two different people.

### Developer

Wants this site set up, maybe in possession of some key elements of its configuration (e.g. SaaS `MONGO_URI` and `GOOGLE_CLIENT_ID`) but likely NOT having AWS permissions to run the terraform themselves.


### AWS Admin

Has sufficient privileges in the relevant AWS account to build all the infrastructure (basically has to be `admin`). Ideally, has AWS expertise to review infrastructure (including the underlying terraform modules used herein and not just the template-local config) with an eye for security and best practices.


## Required Software

 
```
**NOTE** only the `AWS Admin` really needs `terraform` and `terragrunt` installed (to actually deploy the infrastructure). 
```

 The `AWS Admin` MUST have both `terraform` and `terragrunt`. `terragrunt` is a light wrapper over terraform that helps keep terraform DRY, but more importantly for this case, it solves a chicken/egg problem terraform has where you need an s3 state bucket in place to `terraform init`

 The `Developer` with limited AWS perms may also want these tools installed, but mainly for purpose of reading `terraform` output values that are needed in configuration of the actual opentutor app elsewhere (e.g. the id of the `EFS` file system).

 On mac and most linux flavors, you can install both terraform and terragrunt with [homebrew](https://brew.sh/), e.g.

 ```
 brew update
 brew install terraform
 brew install terragrunt
 ```

 Or you check [here for other terraform install methods](https://www.terraform.io/downloads.html) and [here for terragrunt install](https://terragrunt.gruntwork.io/docs/getting-started/install/)


## Required Accounts and Externals

To configure infrastructure for a new opentutor site using this module you will need the following:

- (`AWS Admin`) an `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for an AWS iam with admin permissions

- (`Developer`) a `MONGO_URI` for read/write connections to a [mongodb](https://www.mongodb.com/1) instance (you can use a free mongodb.com instance for this to start)

- (`Developer`) a [GOOGLE_CLIENT_ID](https://developers.google.com/identity/one-tap/web/guides/get-google-api-clientid) for google user authentication

- A domain name and SSL certificate for your opentutor site. Current terraform assumes this is all in AWS with cert in `AWS Certificate Manager` and DNS in `AWS Route 53`)

## Configuring this template for a New Opentutor Site

Once `Developer` has required external software, domains, certs, etc in hand, follow these steps:

- copy the contents of this template (e.g. to a repo of your own)

- edit `terraform.tfvars` with config details for your site

- edit `terragrunt.hcl` with config details for your site

- rename `scret.auto.tfvars` to `secret.auto.tfvars` (so it will be .gitignored) and configure the secrets. Secret management is external (e.g. maybe secrets were shared via 1password)

- Put in whatever best form to share with `AWS Admin`, e.g. branch, Pull Request and Request Review in gitub

## Deploying/Updating the Infrastructure to AWS

Once `AWS Admin` has received and approved the configured terraform.

- make sure AWS credentials are available in shell, e.g.

> ```bash
> export AWS_ACCESS_KEY_ID=<your_id>
> export AWS_SECRET_ACCESS_KEY=<your_secret>
> ```

- in shell from where you put your terraform files do `make apply`

- when prompted with the terraform plan, you have to enter `yes` to proceed

- terraform will run for maybe 20 minutes total (waiting for AWS to build things). When if completes successfully, it will output an `efs_file_system_id` which you will use to configure your app deployment. You can also get the `efs_file_system_id` at any time after the infrastructure is up using `make output-efs_file_system_id`


 ## FAQ

 ### Why execute the terraform manually rather than in CI?

 Really, it would be better to have `terraform` execute in a CI environment based on some specific trigger (e.g. a tag with a `semver` format from `main`.) The reason we don't do this yet is that `github` lacks sufficient tag-permissioning features to securely guarantee that any person with write access to the repo, couldn't trigger an infrastructure update. Github will likely eventually acquire these features (gitlab already has it), so we should revisit periodically.

