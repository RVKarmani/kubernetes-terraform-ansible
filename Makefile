.PHONY: help plan apply destroy all init configure

SHELL := /bin/bash

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

init:           ## Init Terraform
	cd terraform && terraform init

plan:           ## Calculate infrastructure
	cd terraform && terraform plan --var-file ../vars.json

apply:          ## Apply changes to infrastructure
	cd terraform  && terraform apply --var-file ../vars.json

destroy:        ## Destroy infrastructure
	cd terraform && terraform destroy --var-file ../vars.json

configure:      ## Setup nodes
	cd ansible && ansible-playbook playbook.yml

all: help
