ENSURE_INSTALLED=$(PWD)/bin/ensure_installed.sh

.PHONY: terraform
terraform:
	sh $(ENSURE_INSTALLED) terraform

.PHONY: terragrunt
terragrunt: terraform
	sh $(ENSURE_INSTALLED) terragrunt

.terraform: terragrunt
	$(MAKE) init


# `make clean` will get rid of local .terraform folder
# which will force re init of all modules on next `make apply`
# You could also just run `make init`
.PHONY: clean
clean:
	rm -rf .terraform


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
