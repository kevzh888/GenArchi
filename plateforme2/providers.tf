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
  backend "s3" {
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
}

/*provider "azurerm" {
  features {}
}*/
