
PLATFORM_DIR=platform
UTILS_DIR=utils
PLATFORM_VARS=$(PLATFORM_DIR)/production.tfvars

.PHONY: all platform-init platform-apply platform-destroy platform-output utils-init utils-apply utils-destroy generate-utils-vars

all: platform-apply platform-output generate-utils-vars utils-apply

platform-init:
	cd $(PLATFORM_DIR) && terraform init

platform-apply:
	cd $(PLATFORM_DIR) && terraform apply -auto-approve

platform-destroy:
	cd $(PLATFORM_DIR) && terraform destroy -auto-approve

platform-output:
	cd $(PLATFORM_DIR) && terraform output -json > ../utils/platform-outputs.json

generate-utils-vars:
	cd $(PLATFORM_DIR) && ./convert_outputs_to_tfvars.sh

utils-init:
	cd $(UTILS_DIR) && terraform init

utils-apply:
	cd $(UTILS_DIR) && terraform apply -auto-approve

utils-destroy:
	cd $(UTILS_DIR) && terraform destroy -auto-approve
