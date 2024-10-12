terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    /*azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }*/
  }
 /* backend "s3" {
    encrypt        = true
    bucket         = "ga-bucket"
    dynamodb_table = "terraform-state-lock-dynamo"
    key            = "state/terraform.tfstate"
    region         = "eu-west-3"
  }
  required_version = ">= 1.2.0"
}

// Specifies provider parameters
provider "aws" {
  region = var.default-region
  /*access_key = var.aws_access_key
  secret_key = var.aws_secret_key*/
}

/*provider "azurerm" {
  features {}
}*/
