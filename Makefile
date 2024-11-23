.PHONY: all clean build deploy destroy terraform-init terraform-plan terraform-apply terraform-destroy

all: build deploy

clean:
	@rm -rf ./src/dist

build:
	@pnpm -C ./src/ install
	@pnpm -C ./src/ compile
	@pnpm -C ./src/ run bundle

deploy: terraform-init terraform-plan terraform-apply

destroy: terraform-destroy

terraform-init:
	@terraform -chdir=./infra init

terraform-plan:
	@terraform -chdir=./infra plan

terraform-apply:
	@terraform -chdir=./infra apply -auto-approve

terraform-destroy:
	@terraform -chdir=./infra destroy -auto-approve

