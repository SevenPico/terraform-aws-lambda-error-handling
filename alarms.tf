## ----------------------------------------------------------------------------
##  Rate Alarm - When the DLQ is growing
##  takes datapoints to alarm in periods as parameter (see _variables.tf)
## ----------------------------------------------------------------------------


resource "aws_cloudwatch_metric_alarm" "rate_alarm" {
  count             = module.async_lambda_global_error_notification_context.enabled ? 1 : 0
  depends_on        = [var.rate_sns_topic_arn]
  alarm_name        = var.rate_alarm_name != null ? var.rate_alarm_name : "${module.async_lambda_global_error_notification_context.id}-rate"
  alarm_description = "ALARM when the rate of growth for the ${module.lambda_global_error_dlq_context.id} Dead Letter Queue exceeds the threshold"

  metric_query {
    id          = "e1"
    expression  = "RATE(m1)"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = var.alarms_period
      stat        = "Maximum"
      dimensions = {
        QueueName = module.lambda_global_error_dlq_context.id
      }
    }
    return_data = false
  }

  evaluation_periods  = var.alarms_evaluation_periods
  datapoints_to_alarm = var.alarms_datapoints_to_alarm
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "ignore"
  alarm_actions       = [var.rate_sns_topic_arn]
  ok_actions          = [var.rate_sns_topic_arn]
  tags                = module.async_lambda_global_error_notification_context.tags
}


## ----------------------------------------------------------------------------
##  Volume Alarm - When the DLQ has messages remaining to reprocess
##  hardcoded to 1 datapoint to alarm in 1 period to send the notification ASAP
## ----------------------------------------------------------------------------


resource "aws_cloudwatch_metric_alarm" "volume_alarm" {
  count      = module.async_lambda_global_error_notification_context.enabled ? 1 : 0
  depends_on = [var.volume_sns_topic_arn]

  alarm_name          = var.volume_alarm_name != null ? var.volume_alarm_name : "${module.async_lambda_global_error_notification_context.id}-volume"
  alarm_description   = "ALARM when the ${module.lambda_global_error_dlq_context.id} Dead Letter Queue has messages remaining to reprocess"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  statistic           = "Maximum"
  period              = var.alarms_period
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "ignore"
  dimensions = {
    QueueName = module.lambda_global_error_dlq_context.id
  }
  alarm_actions = [var.volume_sns_topic_arn]
  ok_actions    = [var.volume_sns_topic_arn]
  tags          = module.async_lambda_global_error_notification_context.tags
}


## ----------------------------------------------------------------------------
##  IAM Policies
## ----------------------------------------------------------------------------


data "aws_iam_policy_document" "rate_alarm_sns_policy" {
  count = module.async_lambda_global_error_notification_context.enabled ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    actions   = ["sns:Publish"]
    resources = [var.rate_sns_topic_arn]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current[0].partition}:cloudwatch:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:alarm:${module.async_lambda_global_error_notification_context.id}-rate"
      ]
    }
  }
}

data "aws_iam_policy_document" "volume_alarm_sns_policy" {
  count = module.async_lambda_global_error_notification_context.enabled ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    actions   = ["sns:Publish"]
    resources = [var.volume_sns_topic_arn]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current[0].partition}:cloudwatch:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:alarm:${module.async_lambda_global_error_notification_context.id}-volume"
      ]
    }
  }
}

resource "aws_sns_topic_policy" "rate_alarm_policy" {
  count  = module.async_lambda_global_error_notification_context.enabled ? 1 : 0
  arn    = var.rate_sns_topic_arn
  policy = data.aws_iam_policy_document.rate_alarm_sns_policy[0].json
}

resource "aws_sns_topic_policy" "volume_alarm_policy" {
  count  = module.async_lambda_global_error_notification_context.enabled ? 1 : 0
  arn    = var.volume_sns_topic_arn
  policy = data.aws_iam_policy_document.volume_alarm_sns_policy[0].json
}
