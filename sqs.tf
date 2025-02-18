module "lambda_global_error_dlq_context" {
  source  = "registry.terraform.io/SevenPico/context/null"
  version = "2.0.0"
  context = module.async_lambda_global_error_notification_context.self
}

locals {
  sqs_queue_name = var.sqs_queue_name != null ? var.sqs_queue_name : "${module.lambda_global_error_dlq_context.id}-dlq"
}

resource "aws_sqs_queue" "lambda_global_error_dlq" {
  count = module.lambda_global_error_dlq_context.enabled ? 1 : 0

  name                       = local.sqs_queue_name
  message_retention_seconds  = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  kms_master_key_id          = try(var.sqs_kms_key_config.key_id, null)
  tags                       = module.async_lambda_global_error_notification_context.tags
}

data "aws_iam_policy_document" "sqs_publish_policy_doc" {
  count = module.lambda_global_error_dlq_context.enabled ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.lambda_global_error_dlq[0].arn]
  }

  dynamic "statement" {
    for_each = var.sqs_kms_key_config != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ]
      resources = [var.sqs_kms_key_config.key_arn]
    }
  }
}

resource "aws_iam_policy" "sqs_publish_policy" {
  count = module.lambda_global_error_dlq_context.enabled ? 1 : 0

  name        = "${local.sqs_queue_name}-sqs-publish-policy"
  description = "SQS publish policy for lambda."
  policy      = data.aws_iam_policy_document.sqs_publish_policy_doc[0].json
  tags        = module.async_lambda_global_error_notification_context.tags
}

resource "aws_iam_role_policy_attachment" "attach_sqs_publish_policy" {
  count      = module.lambda_global_error_dlq_context.enabled ? 1 : 0
  role       = var.lambda_role_name
  policy_arn = try(aws_iam_policy.sqs_publish_policy[0].arn, null)
}

data "aws_iam_policy_document" "sqs_queue_policy" {
  count = module.lambda_global_error_dlq_context.enabled ? 1 : 0

  statement {
    sid    = "AllowLambdaToSendMessages"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "events.amazonaws.com" # For async Lambda failures
      ]
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.lambda_global_error_dlq[0].arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:lambda:${local.region}:${local.account_id}:function:*",
        "arn:aws:events:${local.region}:${local.account_id}:*"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.sqs_kms_key_config != null ? [1] : []
    content {
      sid    = "AllowPipeToReceiveMessages"
      effect = "Allow"
      principals {
        type        = "Service"
        identifiers = ["pipes.amazonaws.com"]
      }
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      resources = [aws_sqs_queue.lambda_global_error_dlq[0].arn]
      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [local.account_id]
      }
      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = ["arn:aws:pipes:${local.region}:${local.account_id}:pipe/*"]
      }
    }
  }
}

resource "aws_sqs_queue_policy" "lambda_global_error_dlq" {
  count     = module.lambda_global_error_dlq_context.enabled ? 1 : 0
  queue_url = aws_sqs_queue.lambda_global_error_dlq[0].url
  policy    = data.aws_iam_policy_document.sqs_queue_policy[0].json
}
