# 1. Generate a Terraform configuration block that defines required providers, including AWS with source hashicorp/aws and version ~> 5.0. Also include required_version >= 1.6.0.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6.0"
}

# 2. Write a Terraform provider block for AWS that sets the region to us-east-1.
provider "aws" {
  region = var.aws_region
}