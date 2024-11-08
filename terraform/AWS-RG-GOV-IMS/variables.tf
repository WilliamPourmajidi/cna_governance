# AWS Region
variable "region" {
  description = "The AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"  # Change this to your preferred region
}

# API Gateway Settings
variable "api_gateway_name" {
  description = "Name of the API Gateway for telemetry ingestion in RG-GOV-IMS"
  type        = string
  default     = "RG-GOV-IMS-Telemetry-API"
}

variable "api_gateway_stage_name" {
  description = "Stage name for the API Gateway deployment"
  type        = string
  default     = "dev"  # Modify as needed for your environment
}

# SNS Topics
variable "sns_converter_topic_name" {
  description = "Name of the SNS topic for the Converter in RG-GOV-IMS"
  type        = string
  default     = "Converter"
}

variable "sns_archiver_topic_name" {
  description = "Name of the SNS topic for the Archiver in RG-GOV-IMS"
  type        = string
  default     = "Archiver"
}

# S3 Buckets
variable "s3_mutable_bucket_name" {
  description = "Name of the S3 bucket for mutable storage of metrics"
  type        = string
  default     = "rg-gov-ims-mutable-bucket"
}

variable "s3_immutable_bucket_name" {
  description = "Name of the S3 bucket for immutable storage of logs"
  type        = string
  default     = "rg-gov-ims-immutable-bucket"
}

# Lambda Function Settings
variable "api_gateway_lambda_function_name" {
  description = "Name of the Lambda function triggered by the API Gateway"
  type        = string
  default     = "RG_GOV_IMS_APIGatewayHandler"
}

variable "converter_lambda_function_name" {
  description = "Name of the Lambda function triggered by the Converter SNS topic"
  type        = string
  default     = "RG_GOV_IMS_ConverterHandler"
}

variable "archiver_lambda_function_name" {
  description = "Name of the Lambda function triggered by the Archiver SNS topic"
  type        = string
  default     = "RG_GOV_IMS_ArchiverHandler"
}

# Environment Variables for Lambda
variable "archiver_lambda_api_gateway_url" {
  description = "API Gateway URL used by the Archiver Lambda function"
  type        = string
  default     = "https://<api_gateway_id>.execute-api.<region>.amazonaws.com/<stage>/telemetry"  # Replace with actual URL
}
