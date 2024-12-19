# Terraform AWS Async Lambda Error Notification

This project sets up a Lambda function with error notifications using AWS services such as EventBridge, SQS, and SNS. The Lambda function is configured to throw an error based on the input event.

## Architecture Diagram

```mermaid
graph TD;

```

## Modules

- **example_context**: Provides context for the resources.
- **async_lambda_error_notifications**: Sets up the error notification pipeline.
- **example_lambda**: Deploys the Lambda function.
- **example_lambda_role**: Creates the IAM role for the Lambda function.

## Resources

- **Lambda Function**: A simple "Hello World" function that throws an error if `toError` is true in the request event.
- **EventBridge Pipe**: Routes events from the Lambda function to the SQS queue.
- **SQS Queue**: Acts as a dead-letter queue for the Lambda function and reprocesses the messages.
- **SNS Topic**: Sends notifications when errors occur.

## Variables

- `lambda_arn`: The ARN of the Lambda to monitor.
- `sns_topic_arn`: The ARN of the SNS topic for alarm notifications.
- `eventbridge_pipe_name`: The name of the EventBridge Pipe.
- `sqs_queue_name`: The name of the SQS Dead Letter Queue.
- `lambda_role_name`: The IAM role name for the Lambda function.
- `lambda_function_name`: The name of the Lambda function.

## Usage

```hcl
module "example_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["example", "lambda"]
}

module "async_lambda_error_notifications" {
  source                = "../../"
  context               = module.example_context.self
  lambda_arn            = aws_lambda_function.example.arn
  eventbridge_pipe_name = "example-pipe"
  sqs_queue_name        = "example-queue"
  lambda_role_name      = aws_iam_role.example_lambda_role.name
  lambda_function_name  = aws_lambda_function.example.function_name
  sns_topic_arn         = "arn:aws:sns:region:account-id:example-topic"
}
```

## Lambda Function Code

The Lambda function code is located in `lambda/index.js`:

```javascript
exports.handler = async (event) => {
  if (event.toError) {
    throw new Error("Forced error");
  }
  return {
    statusCode: 200,
    body: JSON.stringify("Hello, World!"),
  };
};
```

## License

This project is licensed under the MIT License.
