module "rate_sns_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["volume", "sns"]
}

module "volume_sns_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["rate", "sns"]
}

module "rate_alarm_alert_sns" {
  count   = var.rate_sns_topic_arn == "" ? 1 : 0
  source  = "SevenPico/sns/aws"
  version = "2.0.2"
  context = module.rate_sns_context.self

  kms_master_key_id = var.sns_kms_key_id
  pub_principals    = {}
  sub_principals    = {}
}

module "volume_alarm_alert_sns" {
  count   = var.volume_sns_topic_arn == "" ? 1 : 0
  source  = "SevenPico/sns/aws"
  version = "2.0.2"
  context = module.volume_sns_context.self

  kms_master_key_id = var.sns_kms_key_id
  pub_principals    = {}
  sub_principals    = {}
}
