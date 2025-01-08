module "example_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["example", "lambda"]
}

module "async_lambda_error_notifications" {
  source     = "../../"
  attributes = ["example"]

  context    = module.example_context.self
  lambda_arn = module.example_lambda.arn

  lambda_role_name     = module.example_lambda_role.name
  lambda_function_name = module.example_lambda.function_name
  rate_sns_topic_arn   = ""
  volume_sns_topic_arn = ""
}

module "example_sns" {
  source     = "SevenPico/sns/aws"
  version    = "2.0.2"
  context    = module.example_context.self
  attributes = ["example", "sns"]

  pub_principals = {}
  sub_principals = {}
  tags           = module.example_context.tags
}
