module "lambda_global_error_dlq_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.async_lambda_global_error_notification_context.self
  attributes = [var.sqs_queue_name]
}

resource "aws_sqs_queue" "lambda_global_error_dlq" {
  count = module.lambda_global_error_dlq_context.enabled ? 1 : 0

  name                       = module.lambda_global_error_dlq_context.id
  message_retention_seconds  = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  kms_master_key_id          = var.sqs_kms_key_id
  tags                       = module.context.tags
}

data "aws_iam_policy_document" "sqs_publish_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.lambda_global_error_dlq[0].arn]
  }
}

resource "aws_iam_policy" "sqs_publish_policy" {
  count = module.lambda_global_error_dlq_context.enabled ? 1 : 0

  name        = "${module.lambda_global_error_dlq_context.id}-sqs-publish-policy"
  description = "SQS publish policy for lambda."
  policy      = data.aws_iam_policy_document.sqs_publish_policy_doc.json
}


resource "aws_iam_role_policy_attachment" "attach_sqs_publish_policy" {
  count      = module.lambda_global_error_dlq_context.enabled ? 1 : 0
  role       = var.lambda_role_name
  policy_arn = try(aws_iam_policy.sqs_publish_policy[0].arn, null)
}
