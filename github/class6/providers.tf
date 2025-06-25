
terraform {
  required_version = "1.8.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}
provider "aws" {
  region = "ap-south-1"
  default_tags {
    tags = {
      Owner = "sajitha"
      repo  = "sajithasafrin/learn"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "trial-demo-1234"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}


