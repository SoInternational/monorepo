terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

data "aws_s3_bucket" "this" {
  bucket = var.bucket
}

data "aws_cloudfront_distribution" "this" {
  count = length(var.cloudfront_ids)
  id    = var.cloudfront_ids[count.index]
}

locals {
  statements = [for v in data.aws_cloudfront_distribution.this : {
    Sid    = ""
    Effect = "Allow"
    Principal = {
      Service = "cloudfront.amazonaws.com"
    }
    Action   = "s3:GetObject"
    Resource = "${data.aws_s3_bucket.this.arn}/*"
    Condition = {
      StringEquals = {
        "AWS:SourceArn" : v.arn
      }
    }
  }]
}

resource "aws_s3_bucket_policy" "this" {
  count  = length(local.statements) > 0 ? 1 : 0
  bucket = var.bucket
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.statements
  })
}
