locals {
  rate_topic_arn       = var.rate_sns_topic_arn != "" ? var.rate_sns_topic_arn : module.rate_alarm_alert_sns.topic_arn
  volume_sns_topic_arn = var.volume_sns_topic_arn != "" ? var.volume_sns_topic_arn : module.volume_alarm_alert_sns.topic_arn
}

resource "aws_cloudwatch_metric_alarm" "rate_alarm" {
  count             = module.async_lambda_global_error_notification_context.enabled ? 1 : 0
  alarm_name        = "${module.lambda_global_error_dlq_context.id}-rate"
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
  alarm_actions       = [local.rate_topic_arn]
  ok_actions          = [local.rate_topic_arn]
  tags                = module.async_lambda_global_error_notification_context.tags
}

resource "aws_cloudwatch_metric_alarm" "volume_alarm" {
  count               = module.async_lambda_global_error_notification_context.enabled ? 1 : 0
  alarm_name          = "${module.lambda_global_error_dlq_context.id}-volume"
  alarm_description   = "ALARM when the ${module.lambda_global_error_dlq_context.id} Dead Letter Queue has messages remaining to reprocess"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  statistic           = "Maximum"
  period              = var.alarms_period
  evaluation_periods  = var.alarms_evaluation_periods
  datapoints_to_alarm = var.alarms_datapoints_to_alarm
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "ignore"
  dimensions = {
    QueueName = module.lambda_global_error_dlq_context.id
  }
  alarm_actions = [local.volume_sns_topic_arn]
  ok_actions    = [local.volume_sns_topic_arn]
  tags          = module.async_lambda_global_error_notification_context.tags
}
