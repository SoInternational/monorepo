terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = ".terraform/temp/lambda/${var.name}.zip"
}

module "lambda" {
  source                                  = "terraform-aws-modules/lambda/aws"
  function_name                           = var.name
  role_name                               = "lambda_${var.name}"
  create_package                          = false
  local_existing_package                  = data.archive_file.lambda.output_path
  environment_variables                   = var.environment
  handler                                 = var.handler
  runtime                                 = var.runtime
  create_current_version_allowed_triggers = false
  allowed_triggers = {
    for k, v in var.apigateway_execution_arns : "AllowExecutionFromAPIGateway${k}" => {
      service    = "apigateway"
      source_arn = "${v}/*/*"
    }
  }
  attach_policy_statements = length(keys(var.policy_statements)) > 0
  policy_statements        = var.policy_statements
}
