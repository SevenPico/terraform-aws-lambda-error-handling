# KMS Key for SQS encryption
resource "aws_kms_key" "sqs_kms_key" {
  count                   = module.context.enabled ? 1 : 0
  description             = "KMS key for SQS queue encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current[0].account_id}:root"
        }
        Action   = "kms:*"
        Resource = ["arn:aws:kms:${local.region}:${local.account_id}:key/*"]
      }],
      module.context.enabled ? [{
        Sid    = "Allow Lambda to use the key"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = ["arn:aws:kms:${local.region}:${local.account_id}:key/*"]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:lambda:${local.region}:${local.account_id}:function:*"
          }
        }
        }, {
        Sid    = "Allow EventBridge Pipe to use the key"
        Effect = "Allow"
        Principal = {
          Service = "pipes.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = ["arn:aws:kms:${local.region}:${local.account_id}:key/*"]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:pipes:${local.region}:${local.account_id}:pipe/*"
          }
        }
      }] : []
    )
  })

  tags = module.context.tags
}

# KMS Key for SNS encryption
resource "aws_kms_key" "sns_kms_key" {
  count                   = module.context.enabled ? 1 : 0
  description             = "KMS key for SNS topic encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current[0].account_id}:root"
        }
        Action   = "kms:*"
        Resource = ["arn:aws:kms:${local.region}:${local.account_id}:key/*"]
      },
      {
        Sid    = "Allow CloudWatch Alarms to use the key"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = ["arn:aws:kms:${local.region}:${local.account_id}:key/*"]
        Condition = {
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:cloudwatch:${local.region}:${local.account_id}:alarm:*-rate-alarm",
              "arn:aws:cloudwatch:${local.region}:${local.account_id}:alarm:*-volume-alarm"
            ]
          }
        }
      }
    ]
  })

  tags = module.context.tags
}

resource "aws_kms_alias" "sqs_kms_key_alias" {
  count         = module.context.enabled ? 1 : 0
  name          = "alias/${module.context.id}-sqs-kms-key"
  target_key_id = aws_kms_key.sqs_kms_key[0].key_id
}

resource "aws_kms_alias" "sns_kms_key_alias" {
  count         = module.context.enabled ? 1 : 0
  name          = "alias/${module.context.id}-sns-kms-key"
  target_key_id = aws_kms_key.sns_kms_key[0].key_id
} 