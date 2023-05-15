terraform {
  required_version = ">=1.4.6"
}

resource "null_resource" "s3" {
  triggers = {
    key = length(var.key) > 0 ? var.key : uuid()
  }

  provisioner "local-exec" {
    command = "aws --region=us-east-1 s3 sync '${var.source_dir}' 's3://${var.bucket}'"
    environment = length(var.profile) > 0 ? {
      AWS_PROFILE = var.profile
    } : {}
  }
}
