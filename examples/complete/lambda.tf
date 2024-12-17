resource "archive_file" "hello_world_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.js"
  output_path = "${path.module}/lambda/.dist/index.zip"
}

module "example_lambda" {
  source  = "SevenPicoForks/lambda-function/aws"
  version = "2.0.3"

  context = module.example_context.self

  architectures                       = null
  cloudwatch_event_rules              = {}
  cloudwatch_lambda_insights_enabled  = false
  cloudwatch_logs_kms_key_arn         = null
  cloudwatch_logs_retention_in_days   = var.cloudwatch_log_retention_days
  cloudwatch_log_subscription_filters = {}
  description                         = "Example Lambda function"
  event_source_mappings               = {}
  filename                            = archive_file.hello_world_lambda_zip.output_path
  function_name                       = "example-function"
  handler                             = "index.handler"
  ignore_external_function_updates    = false
  image_config                        = {}
  image_uri                           = null
  kms_key_arn                         = ""
  lambda_at_edge                      = false
  lambda_role_source_policy_documents = []
  layers                              = []
  memory_size                         = 128
  package_type                        = "Zip"
  publish                             = true
  reserved_concurrent_executions      = -1
  role_name                           = module.example_lambda_role.name
  runtime                             = "nodejs20.x"
  s3_bucket                           = null
  s3_key                              = null
  s3_object_version                   = null
  sns_subscriptions                   = {}
  source_code_hash                    = filebase64sha256(archive_file.hello_world_lambda_zip.output_path)
  ssm_parameter_names                 = null
  timeout                             = 10
  tracing_config_mode                 = null
  vpc_config                          = null
  lambda_environment = {
    variables = {
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }
}

module "example_lambda_role" {
  source     = "SevenPicoForks/iam-role/aws"
  version    = "2.0.0"
  context    = module.example_context.self
  attributes = ["role"]

  assume_role_actions      = ["sts:AssumeRole"]
  assume_role_conditions   = []
  instance_profile_enabled = false
  managed_policy_arns      = []
  max_session_duration     = 3600
  path                     = "/"
  permissions_boundary     = ""
  policy_description       = ""
  policy_document_count    = 1
  policy_documents         = []
  principals = {
    Service = ["lambda.amazonaws.com"]
  }
  role_description = "Lambda IAM Role for ${module.example_context.id}"
  tags_enabled     = true
  use_fullname     = true
}
