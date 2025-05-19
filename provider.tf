variable "aws_profile" {
  description = "AWS Profile"
  default     = "inpost-prod"
}

variable "aws_region" {
  description = "AWS Region"
  default     = "eu-central-1"
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Company = "inpost"
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "inpost-terraform"
    key     = "tfstate/inpost.tfstate"
    region  = "eu-central-1"
    profile = "inpost-prod"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.1"
    }
  }
  required_version = ">= 1.2.6"
}