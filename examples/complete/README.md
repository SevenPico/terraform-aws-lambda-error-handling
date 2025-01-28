# Example: Complete

This example shows how to add async error notifications to a given Lambda function. It uses SQS queues and SNS topics which are KMS encrypted.

It deploys the following resources:

- **Lambda Function Event Invoke Config**: Configures async error handling and DLQ destination
- **SQS Dead Letter Queue**: Captures failed async Lambda executions
- **Two CloudWatch Alarms**:
  - Rate-based alarm for monitoring DLQ growth rate
  - Volume-based alarm for monitoring DLQ message count
- **EventBridge Pipe**: (Disabled by default) For reprocessing failed events
- **IAM Role and Policies**: For EventBridge Pipe and SQS permissions
- **CloudWatch Log Group**: For EventBridge Pipe logs

## Prerequisites

- [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [aws cli](https://aws.amazon.com/cli/)

## Environment Variables

Create a `.env` file with the following environment variable exports:

```bash
export AWS_REGION="your-aws-region"
export AWS_DEFAULT_REGION="your-aws-region"
export NAMESPACE="your-namespace"
export TENANT="your-tenant"
export ENVIRONMENT="your-environment"
export ROOT_DOMAIN="your-root-domain"
export TFSTATE_BUCKET="your-tfstate-bucket"
export TFSTATE_LOCK_TABLE="your-tfstate-lock-table"
export ENABLED=false
```

Then run `source .env` to load the environment variables.

## Usage

Use Terragrunt to run the example.
Before running the commands below, get the AWS environment variables for the account you want to deploy to.

```bash
export AWS_ACCESS_KEY_ID="your-aws-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-aws-secret-access-key"
export AWS_SESSION_TOKEN="your-aws-session-token"
```

Then run the following commands to deploy the example:

```bash
terragrunt init
terragrunt plan
terragrunt apply
```

Of course, that will only deploy the context since all the AWS resources are not enabled by default. You must set your environment variable `ENABLED=true` to deploy the AWS resources.

```bash
export ENABLED=true
terragrunt plan
terragrunt apply
```
