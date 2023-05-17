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
    key            = "parking"
    encrypt        = true
  }
}

locals {
  workspace = jsondecode(file("${path.module}/workspace-${terraform.workspace}.json"))
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = [local.workspace.account_id]
}

module "s3" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "parking-${local.account_id}"
}

module "s3-sync" {
  source     = "../../../terraform/modules/s3/sync"
  source_dir = "${path.module}/../dist"
  bucket     = module.s3.s3_bucket_id
}

module "cdn" {
  for_each  = toset(local.workspace.domains)
  source    = "../../../terraform/modules/cdn"
  name      = "parking__${replace(each.value, "/\\W/", "_")}"
  zone_id   = local.zone_ids[each.value]
  domain    = each.value
  aliases   = ["www.${each.value}"]
  s3_bucket = module.s3.s3_bucket_id
}

module "s3-policy" {
  source         = "../../../terraform/modules/s3/policy"
  bucket         = module.s3.s3_bucket_id
  cloudfront_ids = [for v in module.cdn : v.cloudfront_id]
}
