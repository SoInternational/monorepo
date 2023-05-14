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
    dynamodb_table = "tfstate-main-topherland"
    bucket         = "tfstate-main-topherland"
    key            = "chrisackerman.dev"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_route53_zone" "this" {
  name = "chrisackerman.dev"
}

module "dns" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_id = data.aws_route53_zone.this.zone_id
  records = [
    {
      type    = "CNAME"
      name    = "protonmail._domainkey"
      records = ["protonmail.domainkey.din4xz4fokjkq7j66kmoysdksrigfv5dmjolduuoey777ly2vl3ra.domains.proton.ch."]
      ttl     = 300
    },
    {
      type    = "CNAME"
      name    = "protonmail2._domainkey"
      records = ["protonmail2.domainkey.din4xz4fokjkq7j66kmoysdksrigfv5dmjolduuoey777ly2vl3ra.domains.proton.ch."]
      ttl     = 300
    },
    {
      type    = "CNAME"
      name    = "protonmail3._domainkey"
      records = ["protonmail3.domainkey.din4xz4fokjkq7j66kmoysdksrigfv5dmjolduuoey777ly2vl3ra.domains.proton.ch."]
      ttl     = 300
    },
    {
      type = "TXT"
      name = ""
      records = [
        "protonmail-verification=08d9654eb36271ac7815495470ef5f3a08723cf1",
        "v=spf1 include:_spf.protonmail.ch mx ~all"
      ]
      ttl = 300
    },
    {
      type = "TXT"
      name = "_dmarc"
      records = [
        "v=DMARC1; p=none; rua=mailto:dmarc@topher.land"
      ]
      ttl = 300
    },
    {
      type = "MX"
      name = ""
      records = [
        "10 mail.protonmail.ch.",
        "20 mailsec.protonmail.ch."
      ]
      ttl = 300
    }
  ]
}

module "s3" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "chrisackerman.dev"
}

resource "null_resource" "s3-sync" {
  provisioner "local-exec" {
    working_dir = path.module
    command     = "aws s3 sync ../public s3://${module.s3.s3_bucket_id}"
  }
}

module "cdn" {
  source     = "../../../terraform/cdn"
  depends_on = [null_resource.s3-sync]
  zone_id    = data.aws_route53_zone.this.zone_id
  domain     = "chrisackerman.dev"
  aliases    = ["www.chrisackerman.dev"]
  s3_bucket  = module.s3.s3_bucket_id
}
