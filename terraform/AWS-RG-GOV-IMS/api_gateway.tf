# Define the API Gateway
resource "aws_apigateway_rest_api" "rg_gov_ims_telemetry_api" {
  name        = var.api_gateway_name
  description = "API Gateway for telemetry data ingestion in RG-GOV-IMS"
}

# Define API Gateway Resource
resource "aws_apigateway_resource" "telemetry" {
  rest_api_id = aws_apigateway_rest_api.rg_gov_ims_telemetry_api.id
  parent_id   = aws_apigateway_rest_api.rg_gov_ims_telemetry_api.root_resource_id
  path_part   = "telemetry"
}

# Define API Gateway Method
resource "aws_apigateway_method" "post_method" {
  rest_api_id   = aws_apigateway_rest_api.rg_gov_ims_telemetry_api.id
  resource_id   = aws_apigateway_resource.telemetry.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrate API Gateway with Lambda
resource "aws_apigateway_integration" "lambda_integration" {
  rest_api_id             = aws_apigateway_rest_api.rg_gov_ims_telemetry_api.id
  resource_id             = aws_apigateway_resource.telemetry.id
  http_method             = aws_apigateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_gateway_lambda.invoke_arn
}

# Deploy API Gateway
resource "aws_apigateway_deployment" "api_deployment" {
  depends_on = [aws_apigateway_integration.lambda_integration]
  rest_api_id = aws_apigateway_rest_api.rg_gov_ims_telemetry_api.id
  stage_name  = var.api_gateway_stage_name
}

# Grant API Gateway Permission to Invoke Lambda
resource "aws_lambda_permission" "apigateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_gateway_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigateway_rest_api.rg_gov_ims_telemetry_api.execution_arn}/*/*"
}
