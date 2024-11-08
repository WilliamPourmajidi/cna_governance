# SQS Lambda Function for Forwarding Telemetry Data to API Gateway in RG-GOV-IMS
resource "aws_lambda_function" "sqs_forwarder_lambda" {
  function_name = "RG1-SQSForwarderHandler"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.handler"  # Assuming your main handler is named `handler` in `lambda_function.py`
  runtime       = "python3.8"

  # Point to the local zip file in the same folder
  filename = "${path.module}/sqs_lambda.zip"

  environment {
    variables = {
      API_GATEWAY_URL = "https://<api_gateway_id>.execute-api.<region>.amazonaws.com/<stage>/telemetry"
    }
  }
}

# Grant SQS permission to invoke the Lambda function
resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.rg1_telemetry_queue.arn
  function_name    = aws_lambda_function.sqs_forwarder_lambda.arn
  batch_size       = 10
  enabled          = true
}

