module "example_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = []
  enabled    = module.context.enabled
}

locals {
  sqs_kms_config = module.context.enabled ? {
    key_id  = aws_kms_key.sqs_kms_key[0].id
    key_arn = aws_kms_key.sqs_kms_key[0].arn
  } : null
}

module "async_lambda_error_notifications" {
  source     = "../../"
  attributes = []
  context    = module.example_context.self

  lambda_arn           = try(module.example_lambda[0].arn, "")
  lambda_role_name     = try(module.example_lambda[0].role_name, "")
  lambda_function_name = try(module.example_lambda[0].function_name, "")
  rate_sns_topic_arn   = try(module.rate_alarm_alert_sns[0].topic_arn, "")
  volume_sns_topic_arn = try(module.volume_alarm_alert_sns[0].topic_arn, "")

  sqs_kms_key_config = local.sqs_kms_config
}


module "rate_alarm_alert_sns" {
  count      = module.context.enabled ? 1 : 0
  source     = "SevenPico/sns/aws"
  version    = "2.0.2"
  context    = module.example_context.self
  attributes = ["rate", "sns"]

  pub_principals = {}
  sub_principals = {}
  tags           = module.example_context.tags

  kms_master_key_id = module.context.enabled ? aws_kms_key.sns_kms_key[0].id : null
}

module "volume_alarm_alert_sns" {
  count          = module.context.enabled ? 1 : 0
  source         = "SevenPico/sns/aws"
  version        = "2.0.2"
  context        = module.example_context.self
  attributes     = ["volume", "sns"]
  pub_principals = {}
  sub_principals = {}
  tags           = module.example_context.tags

  kms_master_key_id = module.context.enabled ? aws_kms_key.sns_kms_key[0].id : null
}