terraform {
  required_version = "~> 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75.0"
    }

    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.20.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
