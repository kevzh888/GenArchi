#!/bin/bash

terraform init
terraform plan -var-file="variables.tfvars"
terraform apply -var-file="variables.tfvars" -auto-approve
terraform output