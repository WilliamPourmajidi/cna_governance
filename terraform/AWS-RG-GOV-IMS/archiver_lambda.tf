# IAM Role for Archiver Lambda
resource "aws_iam_role" "archiver_lambda_role" {
  name = "${var.archiver_lambda_function_name}_role"

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

# Attach Policy to Allow Lambda to Log to CloudWatch and Write to S3
resource "aws_iam_role_policy" "archiver_lambda_policy" {
  name   = "${var.archiver_lambda_function_name}_policy"
  role   = aws_iam_role.archiver_lambda_role.id
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
          "s3:PutObject"
        ],
        "Resource": [
          "arn:aws:s3:::${var.s3_mutable_bucket_name}/*",
          "arn:aws:s3:::${var.s3_immutable_bucket_name}/*"
        ]
      }
    ]
  })
}

# Define the Archiver Lambda Function
resource "aws_lambda_function" "archiver_lambda" {
  function_name = var.archiver_lambda_function_name
  role          = aws_iam_role.archiver_lambda_role.arn
  handler       = "lambda_function.handler"  # Assuming the handler function in your Python code is named `handler`
  runtime       = "python3.8"

  # Point to the local zip file for the function code
  filename = "${path.module}/archiver_lambda.zip"

  environment {
    variables = {
      MUTABLE_BUCKET_NAME   = var.s3_mutable_bucket_name,
      IMMUTABLE_BUCKET_NAME = var.s3_immutable_bucket_name
    }
  }

  # Optional: Set timeout and memory size based on expected processing needs
  timeout      = 10    # seconds
  memory_size  = 128   # MB
}

# SNS Subscription for Archiver Topic
resource "aws_sns_topic_subscription" "archiver_topic_subscription" {
  topic_arn = aws_sns_topic.archiver_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.archiver_lambda.arn
}

# Allow SNS to Invoke Archiver Lambda
resource "aws_lambda_permission" "archiver_sns_invocation" {
  statement_id  = "AllowSNSInvokeArchiverLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.archiver_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.archiver_topic.arn
}
