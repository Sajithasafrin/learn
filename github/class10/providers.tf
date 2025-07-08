terraform {
  required_version = "1.8.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.32.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# remote backend
terraform {
  backend "s3" {
    bucket         = "trial-demo-1234"
    key            = "lambda/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}