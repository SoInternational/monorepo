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
    key            = "chrisackerman.dev"
    encrypt        = true
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = [local.workspace.account_id]
}

data "aws_route53_zone" "this" {
  name = local.workspace.zone
}

module "dns" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_id = data.aws_route53_zone.this.zone_id
  records = [for record in local.workspace.records : merge({ ttl = 300 }, record)]
}
