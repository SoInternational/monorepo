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
    key            = "sointernational.love"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_route53_zone" "this" {
  name = "sointernational.love"
}

module "dns" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_id = data.aws_route53_zone.this.zone_id
  records = [
    {
      type    = "CNAME"
      name    = "protonmail._domainkey"
      records = ["protonmail.domainkey.dnmdzwydeucbhtto7i3v2ew726ehknm5gc3hagajihekw3ornr5aq.domains.proton.ch."]
      ttl     = 300
    },
    {
      type    = "CNAME"
      name    = "protonmail2._domainkey"
      records = ["protonmail2.domainkey.dnmdzwydeucbhtto7i3v2ew726ehknm5gc3hagajihekw3ornr5aq.domains.proton.ch."]
      ttl     = 300
    },
    {
      type    = "CNAME"
      name    = "protonmail3._domainkey"
      records = ["protonmail3.domainkey.dnmdzwydeucbhtto7i3v2ew726ehknm5gc3hagajihekw3ornr5aq.domains.proton.ch."]
      ttl     = 300
    },
    {
      type = "TXT"
      name = ""
      records = [
        "protonmail-verification=a1ba68c3e1aa934f4899efab4e06b4099ff46aeb",
        "v=spf1 include:_spf.protonmail.ch mx ~all"
      ]
      ttl = 300
    },
    {
      type = "TXT"
      name = "_dmarc"
      records = [
        "v=DMARC1; p=none; rua=mailto:dmarc@sointernational.love"
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
