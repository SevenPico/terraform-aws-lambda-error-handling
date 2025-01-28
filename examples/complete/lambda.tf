locals {
  lambda_name = "${module.context.id}-fail-function"
}

data "archive_file" "lambda_zip" {
  count = module.context.enabled ? 1 : 0

  type        = "zip"
  source_file = "${path.module}/lambda/index.js"
  output_path = "${path.module}/lambda/index.zip"
}

module "example_lambda" {
  count   = module.context.enabled ? 1 : 0
  enabled = module.context.enabled
  source  = "registry.terraform.io/SevenPicoForks/lambda-function/aws"
  version = "2.0.3"

  function_name = local.lambda_name
  role_name     = "${local.lambda_name}-role"
  description   = "Always fails with an error for testing global error notifications on async lambda"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  timeout       = 30
  memory_size   = 128
  publish       = false

  filename         = data.archive_file.lambda_zip[0].output_path
  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256

  lambda_environment = {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tags = merge(
    module.context.tags,
    {
      Name = local.lambda_name
    }
  )
}
