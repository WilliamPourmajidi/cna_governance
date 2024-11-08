# Define the IAM Role for the Lambda function with necessary permissions
resource "aws_iam_role" "lambda_execution_role" {
  name = "RG1_Lambda_Execution_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach a basic execution policy to allow Lambda to log to CloudWatch
resource "aws_iam_policy_attachment" "lambda_execution_policy" {
  name       = "RG1_Lambda_Execution_Policy_Attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom IAM policy for SQS permissions
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "RG1LambdaSQSPolicy"
  description = "Custom policy for Lambda to access SQS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.rg1_telemetry_queue.arn
      }
    ]
  })
}

# Attach the custom SQS policy to the Lambda role
resource "aws_iam_policy_attachment" "lambda_sqs_policy_attachment" {
  name       = "RG1_Lambda_SQS_Policy_Attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

# API Gateway Lambda Function for Processing Telemetry Data
resource "aws_lambda_function" "api_gateway_lambda" {
  function_name = "RG1-APIGatewayHandler"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.handler"  # Assuming your main handler is named `handler` in `lambda_function.py`
  runtime       = "python3.8"

  # Point to the local zip file in the same folder
  filename = "${path.module}/api_gateway_lambda.zip"

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.rg1_telemetry_queue.id
    }
  }
}
