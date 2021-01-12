# Terraform Template for a new Opentutor site on AWS Elastic Beanstalk

## Required Software Etc.

To create infrastructure for a new opentutor site using this module you will need the following:

- an `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for an AWS iam with admin permissions

- a `MONGO_URI` for read/write connections to a [mongodb](https://www.mongodb.com/1) instance (you can use a free mongodb.com instance for this to start)

- a [GOOGLE_CLIENT_ID](https://developers.google.com/identity/one-tap/web/guides/get-google-api-clientid) for google user authentication

- terraform (can be installed via `brew install terraform` on mac and most linux)

- terragrunt (can also be installed via `brew install terragrunt` on mac and most linux)

## Creating a New Opentutor Site

Once required software and AWS access is set up, follow these steps:

- copy the contents of this template (e.g. to a repo of your own)

- edit `terraform.tfvars` with the names, aws region, etc. for your site

- edit `terragrunt.hcl` with names for your site

- in same folder, create a file `secret.auto.tfvars` with content like the following:

> ```hcl
> eb_env_env_vars = {
>  "MONGO_URI" = <your_mongo_uri>
>  "GOOGLE_CLIENT_ID" = <your_google_client_id>
> }
> ```

- make sure AWS credentials are available in shell, e.g.

> ```bash
> export AWS_ACCESS_KEY_ID=<your_id>
> export AWS_SECRET_ACCESS_KEY=<your_secret>
> ```

- in shell from where you put your terraform files do `make apply`

- when prompted with the terraform plan, you have to enter `yes` to proceed

- terraform will run for maybe 20 minutes total (waiting for AWS to build things). When if completes successfully, it will output an `efs_file_system_id` which you will use to configure your app deployment. You can also get the `efs_file_system_id` at any time after the infrastructure is up using `make output-efs_file_system_id`


 ## Required Software

 Needs both `terraform` and `terragrunt`. `terragrunt` is a light wrapper over terraform that helps keep terraform DRY, but more importantly for this case, it solves a chicken/egg problem terraform has where you need an s3 state bucket in place to `terraform init`

 On mac and most linux flavors, you can install both terraform and terragrunt with [homebrew](https://brew.sh/), e.g.

 ```
 brew update
 brew install terraform
 brew install terragrunt
 ```

 Or you check [here for other terraform install methods](https://www.terraform.io/downloads.html) and [here for terragrunt install](https://terragrunt.gruntwork.io/docs/getting-started/install/)

