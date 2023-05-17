data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  for_each = toset(local.workspace.domains)
  name     = each.value
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  zone_ids   = { for k, v in data.aws_route53_zone.this : k => v.zone_id }
}
