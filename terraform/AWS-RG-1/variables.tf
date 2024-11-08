# AWS Region
variable "region" {
  description = "The AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"  # Modify this default as needed
}

# API Gateway Settings
variable "api_gateway_name" {
  description = "Name of the API Gateway for telemetry ingestion"
  type        = string
  default     = "RG1-Telemetry-API"
}

variable "api_gateway_stage_name" {
  description = "Stage name for the API Gateway deployment"
  type        = string
  default     = "dev"  # Example stage name, adjust as needed
}

# SQS Queue Settings
variable "sqs_queue_name" {
  description = "Name of the SQS queue for telemetry data"
  type        = string
  default     = "RG-1-Telemetry-Queue-US-East"
}

variable "sqs_message_retention_seconds" {
  description = "Number of seconds for SQS to retain messages"
  type        = number
  default     = 86400  # 1 day
}

variable "sqs_visibility_timeout_seconds" {
  description = "Visibility timeout in seconds for the SQS queue"
  type        = number
  default     = 30
}

# Lambda Function Settings
variable "api_gateway_lambda_function_name" {
  description = "Name of the Lambda function triggered by the API Gateway"
  type        = string
  default     = "RG1-APIGatewayHandler"
}

variable "sqs_lambda_function_name" {
  description = "Name of the Lambda function triggered by SQS queue"
  type        = string
  default     = "RG1-SQSForwarderHandler"
}

# IAM Role Settings
variable "lambda_execution_role_name" {
  description = "Name of the IAM role for Lambda function execution"
  type        = string
  default     = "RG1_Lambda_Execution_Role"
}

# Environment Variables for Lambda
variable "api_gateway_url" {
  description = "URL for the API Gateway in RG-GOV-IMS, to be used by the SQS Lambda function"
  type        = string
  default     = "https://<api_gateway_id>.execute-api.<region>.amazonaws.com/<stage>/telemetry"  # Replace with actual URL
}
