# Provider
provider "aws" {
  region = var.region
}

# API Gateway Rest API
resource "aws_api_gateway_rest_api" "rg1_api" {
  name        = "RG1-Telemetry-API"
  description = "API Gateway for receiving telemetry data in AWS-RG-1"
}

# Resource Path
resource "aws_api_gateway_resource" "telemetry_resource" {
  rest_api_id = aws_api_gateway_rest_api.rg1_api.id
  parent_id   = aws_api_gateway_rest_api.rg1_api.root_resource_id
  path_part   = "telemetry"
}

# HTTP Method (POST) Integration with Lambda
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.rg1_api.id
  resource_id   = aws_api_gateway_resource.telemetry_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrate API Gateway with Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rg1_api.id
  resource_id             = aws_api_gateway_resource.telemetry_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_gateway_lambda.invoke_arn

  depends_on = [aws_lambda_permission.api_gateway_permission]
}

# Deployment for API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.rg1_api.id
  stage_name  = var.stage_name
}

# Lambda Permission to Allow Invocation from API Gateway
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_gateway_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rg1_api.execution_arn}/*/${aws_api_gateway_method.post_method.http_method}/${aws_api_gateway_resource.telemetry_resource.path_part}"
}

