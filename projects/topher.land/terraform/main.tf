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
    key            = "topher.land"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_route53_zone" "this" {
  name = "topher.land"
}

module "dns" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_id = data.aws_route53_zone.this.zone_id
  records = [
    {
      type    = "CNAME"
      name    = "protonmail._domainkey"
      records = ["protonmail.domainkey.denixfa7z5rzhtghqq5bustpq2pcvh2rat72fej5xzl2ejszisudq.domains.proton.ch."]
      ttl     = 300
    },
    {
      type    = "CNAME"
      name    = "protonmail2._domainkey"
      records = ["protonmail2.domainkey.denixfa7z5rzhtghqq5bustpq2pcvh2rat72fej5xzl2ejszisudq.domains.proton.ch."]
      ttl     = 300
    },
    {
      type    = "CNAME"
      name    = "protonmail3._domainkey"
      records = ["protonmail3.domainkey.denixfa7z5rzhtghqq5bustpq2pcvh2rat72fej5xzl2ejszisudq.domains.proton.ch."]
      ttl     = 300
    },
    {
      type = "TXT"
      name = ""
      records = [
        "protonmail-verification=bb0f944f6c78f1a147feb26c13a3048ca44556de",
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
