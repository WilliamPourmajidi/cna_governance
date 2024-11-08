# IAM Role for Converter Lambda
resource "aws_iam_role" "converter_lambda_role" {
  name = "${var.converter_lambda_function_name}_role"

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
resource "aws_iam_role_policy" "converter_lambda_policy" {
  name   = "${var.converter_lambda_function_name}_policy"
  role   = aws_iam_role.converter_lambda_role.id
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
        "Resource": aws_sns_topic.archiver_topic.arn
      }
    ]
  })
}

# Define the Converter Lambda Function
resource "aws_lambda_function" "converter_lambda" {
  function_name = var.converter_lambda_function_name
  role          = aws_iam_role.converter_lambda_role.arn
  handler       = "lambda_function.handler"  # Assuming the handler function in your Python code is named `handler`
  runtime       = "python3.8"

  # Point to the local zip file for the function code
  filename = "${path.module}/converter_lambda.zip"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.archiver_topic.arn
    }
  }

  # Optional: Set timeout and memory size based on expected processing needs
  timeout      = 10    # seconds
  memory_size  = 128   # MB
}

# SNS Subscription for Converter Topic
resource "aws_sns_topic_subscription" "converter_topic_subscription" {
  topic_arn = aws_sns_topic.converter_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.converter_lambda.arn
}

# Allow SNS to Invoke Converter Lambda
resource "aws_lambda_permission" "converter_sns_invocation" {
  statement_id  = "AllowSNSInvokeConverterLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.converter_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.converter_topic.arn
}
