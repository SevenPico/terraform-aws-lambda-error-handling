resource "aws_lambda_function_event_invoke_config" "invoke_config" {
  count                        = module.async_lambda_global_error_notification_context.enabled ? 1 : 0
  function_name                = var.lambda_function_name
  maximum_event_age_in_seconds = var.lambda_async_config_maximum_event_age_in_seconds
  maximum_retry_attempts       = var.lambda_async_config_maximum_retry_attempts

  destination_config {
    on_failure {
      destination = aws_sqs_queue.lambda_global_error_dlq[0].arn
    }
  }
}
