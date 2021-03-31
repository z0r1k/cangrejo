.PHONY: all plan apply

PLAN_FILE="out.tfplan"

all: plan apply

plan:
	@echo "✨ Starting terraform magic... 🧙"
	@terraform init
	@terraform plan -var-file="local.tfvars" -out="${PLAN_FILE}"

apply:
	@echo "✨ Applying changes... 🚀"
	@terraform apply ${PLAN_FILE}
