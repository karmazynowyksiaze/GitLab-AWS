terraform {
  required_providers {
    aws = {
        source = "hasicorp/aws"
        version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}