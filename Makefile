SHELL := /bin/bash
TF ?= terraform

init:
	cd envs/dev && $(TF) init

plan:
	cd envs/dev && $(TF) plan -var-file=terraform.tfvars

apply:
	cd envs/dev && $(TF) apply -auto-approve -var-file=terraform.tfvars

destroy:
	cd envs/dev && $(TF) destroy -auto-approve -var-file=terraform.tfvars

kubeconfig:
	cd envs/dev && $(TF) output -raw kubeconfig > kubeconfig && echo "export KUBECONFIG=$$(pwd)/kubeconfig"
