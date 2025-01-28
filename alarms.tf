## ----------------------------------------------------------------------------
##  Rate Alarm - When the DLQ is growing
##  takes datapoints to alarm in periods as parameter (see _variables.tf)
## ----------------------------------------------------------------------------


resource "aws_cloudwatch_metric_alarm" "rate_alarm" {
  count             = module.async_lambda_global_error_notification_context.enabled ? 1 : 0
  depends_on        = [var.rate_sns_topic_arn]
  alarm_name        = var.rate_alarm_name != null ? var.rate_alarm_name : "${module.async_lambda_global_error_notification_context.id}-rate-alarm"
  alarm_description = "Dead Letter Queue `${aws_sqs_queue.lambda_global_error_dlq[0].name}`'s rate of growth exceeds the threshold"

  metric_query {
    id          = "e1"
    expression  = "RATE(m1)"
    return_data = true
    label       = "Rate of Change of ApproximateNumberOfMessagesVisible"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = var.alarms_period
      stat        = "Maximum"
      dimensions = {
        QueueName = aws_sqs_queue.lambda_global_error_dlq[0].name
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

  alarm_name          = var.volume_alarm_name != null ? var.volume_alarm_name : "${module.async_lambda_global_error_notification_context.id}-volume-alarm"
  alarm_description   = "Dead Letter Queue `${aws_sqs_queue.lambda_global_error_dlq[0].name}` has messages remaining to reprocess"
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
    QueueName = aws_sqs_queue.lambda_global_error_dlq[0].name
  }
  alarm_actions = [var.volume_sns_topic_arn]
  ok_actions    = [var.volume_sns_topic_arn]
  tags          = module.async_lambda_global_error_notification_context.tags
}
