terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  // State Lock
   backend "s3" {
    bucket = "ga-s3bucket-tfstate"
    key    = "plateform3/terraform.tfstate"
    region = "eu-west-3"
  }
  required_version = ">= 1.2.0"
}

// Specifies provider parameters
provider "aws" {
  region = var.var_aws_region
  access_key = var.var_aws_access_key
  secret_key = var.var_aws_secret_key
}
