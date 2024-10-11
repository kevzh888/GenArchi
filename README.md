# GenArchi
## Cloud Providers
<img src="https://img.shields.io/badge/Amazon_AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" />
<img src="https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" />
<img src="https://img.shields.io/badge/Openstack-%23f01742.svg?style=for-the-badge&logo=openstack&logoColor=white"/>

## Tech Stack
<img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />

<img src="https://img.shields.io/badge/Ansible-000000?style=for-the-badge&logo=ansible&logoColor=white" />

## Requirement 
- Install terraform -> [How to install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Install Ansible -> [How to install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 
- Have Root AWS access (My account credentials)

## Getting started

### Set up the AWS infra
First set up the Aws credentials as environment variables (ask me for the aws_credentials.sh file)
```
./aws_credentials.sh
```

Set up the aws infrastructure with terraform
```
cd terraform
terraform init
terraform fmt
terraform plan 
terraform apply
```

Now the infrastructure on AWS should be set ! 