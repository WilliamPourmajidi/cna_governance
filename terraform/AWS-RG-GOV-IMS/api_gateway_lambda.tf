# IAM Role for API Gateway Lambda
resource "aws_iam_role" "api_gateway_lambda_role" {
  name = "${var.api_gateway_lambda_function_name}_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

# Attach Policy to Allow Lambda to Log to CloudWatch and Publish to SNS
resource "aws_iam_role_policy" "api_gateway_lambda_policy" {
  name   = "${var.api_gateway_lambda_function_name}_policy"
  role   = aws_iam_role.api_gateway_lambda_role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.region}:*:*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "sns:Publish"
        ],
        "Resource": aws_sns_topic.converter_topic.arn
      }
    ]
  })
}

# Define the API Gateway Lambda Function
resource "aws_lambda_function" "api_gateway_lambda" {
  function_name = var.api_gateway_lambda_function_name
  role          = aws_iam_role.api_gateway_lambda_role.arn
  handler       = "lambda_function.handler"  # Assuming your main handler function is `handler` in `lambda_function.py`
  runtime       = "python3.8"

  # Point to the local zip file in the same folder
  filename = "${path.module}/api_gateway_lambda.zip"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.converter_topic.arn
    }
  }

  # Optional: Set timeout and memory size
  timeout      = 10    # seconds
  memory_size  = 128   # MB
}

# Set up SNS Topic for Converter
resource "aws_sns_topic" "converter_topic" {
  name = var.sns_converter_topic_name
}
