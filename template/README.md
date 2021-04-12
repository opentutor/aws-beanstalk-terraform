# Terraform Template for a new Opentutor site on AWS Elastic Beanstalk

## Required Software Etc.

To create infrastructure for a new opentutor site using this module you will need the following:

- an `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for an AWS iam with admin permissions

- terraform (can be installed via `brew install terraform` on mac and most linux)

- terragrunt (can also be installed via `brew install terragrunt` on mac and most linux)

## Creating a New Opentutor Site

Once required software and AWS access is set up, follow these steps:

- copy the contents of this template (e.g. to a repo of your own)

- edit `terraform.tfvars` with the correct names, region, etc.

- in same folder, create a file `secret.auto.tfvars` with content like the following:

```hcl
"secret_mongo_uri" = "<your full srv mongo uri>"
"secret_jwt_secret" = "<your jwt secret>"

secret_api_secret = "<your api secret>"
```

- make sure AWS credentials are available in shell, e.g.

```bash
export AWS_ACCESS_KEY_ID=<your_id>
export AWS_SECRET_ACCESS_KEY=<your_secret>
```

 ## Required Software

 Needs both `terraform` and `terragrunt`. `terragrunt` is a light wrapper over terraform that helps keep terraform DRY, but more importantly for this case, it solves a chicken/egg problem terraform has where you need an s3 state bucket in place to `terraform init`

 On mac and most linux flavors, you can install both terraform and terragrunt with [homebrew](https://brew.sh/), e.g.

 ```
 brew update
 brew install terraform
 brew install terragrunt
 ```

 Or you check [here for other terraform install methods](https://www.terraform.io/downloads.html) and [here for terragrunt install](https://terragrunt.gruntwork.io/docs/getting-started/install/)


## Deploying Changes 

Step 1: Initialize terraform modules:
```
terragrunt init`
```
Note: if this is the first time deploying the site, then it will ask you to create an S3 bucket and dynamo db table.  Say yes.

Step 2: Apply the terraform:
when you run terraform apply it will calculate all the changes it is going to make.  It then displays the changeset and asks you whether you want to proceed.
ALWAYS review the changeset
```
terragrunt apply
```