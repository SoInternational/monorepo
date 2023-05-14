terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

module "acm" {
  source              = "terraform-aws-modules/acm/aws"
  zone_id             = var.zone_id
  domain_name         = var.domain
  wait_for_validation = true
}

module "api" {
  source                      = "terraform-aws-modules/apigateway-v2/aws"
  name                        = length(var.name) > 0 ? var.name : "${var.protocol_type}_${var.domain}"
  protocol_type               = var.protocol_type
  cors_configuration          = var.cors
  domain_name                 = var.domain
  domain_name_certificate_arn = module.acm.acm_certificate_arn
  integrations = { for route, options in var.integrations : route => merge({
    payload_format_version = "2.0"
  }, options) }
}

module "dns" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_id = var.zone_id
  records = [
    {
      name               = var.domain
      full_name_override = true
      type               = "A"
      alias = {
        name                   = module.api.apigatewayv2_domain_name_configuration[0].target_domain_name
        zone_id                = module.api.apigatewayv2_domain_name_configuration[0].hosted_zone_id
        evaluate_target_health = false
      }
    }
  ]
}
