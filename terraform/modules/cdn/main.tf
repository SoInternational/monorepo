terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

module "acm" {
  source                    = "terraform-aws-modules/acm/aws"
  zone_id                   = var.zone_id
  domain_name               = var.domain
  subject_alternative_names = var.aliases
  wait_for_validation       = true
  tags                      = { Name = var.name }
}

resource "aws_cloudfront_cache_policy" "this" {
  for_each = {
    mutable   = 0
    immutable = 63072000
  }
  name        = "${var.name}__${each.key}"
  min_ttl     = 0
  default_ttl = each.value
  max_ttl     = 63072000
  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "this" {
  for_each = {
    mutable   = "max-age=0"
    immutable = "max-age=63072000, immutable"
  }
  name = "${var.name}__${each.key}"
  custom_headers_config {
    items {
      header   = "cache-control"
      value    = each.value
      override = false
    }
  }
  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "no-referrer"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    content_security_policy {
      content_security_policy = var.content_security_policy
      override                = true
    }
  }
}

module "cloudfront" {
  source              = "terraform-aws-modules/cloudfront/aws"
  comment             = var.name
  aliases             = concat([var.domain], var.aliases)
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  viewer_certificate = {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }
  create_origin_access_control = true
  origin_access_control = {
    "${var.name}__s3_oac" = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }
  origin = {
    primary = {
      domain_name           = local.s3_bucket_regional_domain
      origin_access_control = "${var.name}__s3_oac"
    }
  }
  default_cache_behavior = {
    target_origin_id           = "primary"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    use_forwarded_values       = false
    cache_policy_id            = aws_cloudfront_cache_policy.this["mutable"].id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.this["mutable"].id
  }
  ordered_cache_behavior = [
    {
      path_pattern               = "/assets/*"
      target_origin_id           = "primary"
      viewer_protocol_policy     = "redirect-to-https"
      allowed_methods            = ["GET", "HEAD", "OPTIONS"]
      cached_methods             = ["GET", "HEAD"]
      compress                   = true
      use_forwarded_values       = false
      cache_policy_id            = aws_cloudfront_cache_policy.this["immutable"].id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.this["immutable"].id
    }
  ]
  custom_error_response = [
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    },
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    },
  ]
}

module "dns" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_id = var.zone_id
  records = [for alias in concat([var.domain], var.aliases) : {
    name               = alias
    full_name_override = true
    type               = "A"
    alias = {
      name    = module.cloudfront.cloudfront_distribution_domain_name
      zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
    }
  }]
}
