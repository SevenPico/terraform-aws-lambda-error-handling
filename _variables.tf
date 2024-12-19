variable "lambda_arn" {
  description = "The ARN of the Lambda to monitor."
  type        = string
}

variable "sns_topic_arn" {
  description = "(Optional) The ARN of the SNS topic for alarm notifications. Defaults to an empty string."
  type        = string
  default     = ""
}

variable "alarms_period" {
  description = "(Optional) Period in seconds for CloudWatch alarms. Defaults to 60 seconds."
  type        = number
  default     = 60
}

variable "alarms_datapoints_to_alarm" {
  description = "(Optional) Number of data points that must breach to trigger the alarm. Defaults to 2."
  type        = number
  default     = 2
}

variable "alarms_evaluation_periods" {
  description = "(Optional) Number of periods over which data is compared to the specified threshold. Defaults to 2."
  type        = number
  default     = 2
}

variable "eventbridge_pipe_name" {
  description = "The name of the Pipe. (Context will be added as a prefix)"
  type        = string
}

variable "eventbridge_pipe_batch_size" {
  description = "(Optional) Batch size for EventBridge Pipe processing. Defaults to 1."
  type        = number
  default     = 1
}

variable "eventbridge_pipe_log_level" {
  description = "(Optional) Logging level for EventBridge Pipe. Defaults to 'ERROR'."
  type        = string
  default     = "ERROR"
}

variable "cloudwatch_log_retention_days" {
  description = "(Optional) The number of days to retain logs in AWS CloudWatch before they are automatically deleted. Defaults to 90 days."
  type        = number
  default     = 90
}

variable "target_lambda_input_template" {
  description = "(Optional) The event transformation template for Lambda. Defaults to '<$.requestPayload>'."
  type        = string
  default     = "<$.requestPayload>"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function."
  type        = string
}

variable "lambda_async_config_maximum_event_age_in_seconds" {
  description = "(Optional) The maximum age of a request that Lambda sends to a function for processing. Defaults to 3600 seconds (1 hour)."
  type        = number
  default     = 3600 # 1 hour
}

variable "lambda_async_config_maximum_retry_attempts" {
  description = "(Optional) The maximum number of times to retry when the function returns an error. Defaults to 2 retries."
  type        = number
  default     = 2 # 2 retries
}

variable "sqs_queue_name" {
  description = "Name of the SQS Dead Letter Queue. "
  type        = string
}

variable "sqs_message_retention_seconds" {
  description = "(Optional) SQS message retention period in seconds. Defaults to 604800 seconds (7 days)."
  type        = number
  default     = 604800
}

variable "sqs_visibility_timeout_seconds" {
  description = "(Optional) SQS visibility timeout in seconds. Defaults to 2 seconds."
  type        = number
  default     = 2
}

variable "sqs_kms_key_id" {
  description = "(Optional) Managed key for encryption at rest. Defaults to null."
  type        = string
  default     = null
}

variable "sns_kms_key_id" {
  description = "(Optional) Managed key for encryption at rest. Defaults to null."
  type        = string
  default     = null
}

variable "lambda_role_name" {
  description = "Iam Role arn of the lambda."
  type        = string
}

variable "rate_sns_topic_arn" {
  description = "ARN of the SNS topic for rate alarm notifications. Defaults to an empty string."
  type        = string
}

variable "volume_sns_topic_arn" {
  description = "ARN of the SNS topic for volume alarm notifications. Defaults to an empty string."
  type        = string
}
