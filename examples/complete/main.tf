module "example_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["example", "lambda"]
}

module "async_lambda_error_notifications" {
  source                = "../../"
  context               = module.example_context.self
  lambda_arn            = module.example_lambda.arn
  eventbridge_pipe_name = "example-pipe"
  sqs_queue_name        = "example-queue"
  lambda_role_name      = module.example_lambda_role.name
  lambda_function_name  = module.example_lambda.function_name
}
