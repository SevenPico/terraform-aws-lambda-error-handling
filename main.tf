module "async_lambda_global_error_notification_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = var.context
  attributes = []
}
