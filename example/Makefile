ENSURE_INSTALLED=$(PWD)/bin/ensure_installed.sh

.PHONY: terraform
terraform:
	sh $(ENSURE_INSTALLED) terraform

.PHONY: terragrunt
terragrunt: terraform
	sh $(ENSURE_INSTALLED) terragrunt

.terraform: terragrunt
	$(MAKE) init

.PHONY: init
init: terragrunt
	terragrunt init

.PHONY: apply
apply: .terraform
	terragrunt apply --terragrunt-debug

.PHONY: output-%
tf-output-%: .terraform
	terragrunt output $*

.PHONY: output-%
output-efs_file_system_id:
	$(MAKE) tf-output-efs_file_system_id
