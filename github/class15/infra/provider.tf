terraform {
  required_version = "1.8.1"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
terraform {
  backend "s3" {}
}