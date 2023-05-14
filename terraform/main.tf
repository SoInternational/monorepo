terraform {
  required_version = ">=1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }

  backend "s3" {
    region         = "us-east-1"
    dynamodb_table = "tfstate-lock"
    bucket         = "tfstate-433680868508"
    key            = "root"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "zones" {
  source = "terraform-aws-modules/route53/aws//modules/zones"
  zones = {
    "topher.land"          = {}
    "chrisackerman.dev"    = {}
    "sointernational.love" = {}
    "minstack.rocks"       = {}
  }
}
