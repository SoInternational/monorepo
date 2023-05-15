data "aws_s3_bucket" "this" {
  bucket = var.s3_bucket
}

locals {
  s3_bucket                 = data.aws_s3_bucket.this.id
  s3_bucket_arn             = data.aws_s3_bucket.this.arn
  s3_bucket_regional_domain = data.aws_s3_bucket.this.bucket_regional_domain_name
}
