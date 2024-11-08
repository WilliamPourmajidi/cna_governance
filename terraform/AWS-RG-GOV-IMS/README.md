# AWS-RG-GOV-IMS Terraform Configuration

This folder contains Terraform configurations for deploying resources in the `AWS-RG-GOV-IMS` resource group. The resources include an `AWS API Gateway` integrated with a Lambda function, an `AWS SNS` service with two topics (Converter and Archiver), and two `AWS S3` buckets for mutable and immutable storage.

This setup facilitates the processing and archiving of telemetry data in a fault-tolerant manner. The API Gateway receives telemetry data, which is processed by an attached Lambda function that adds the `RG_GOV_IMS_API_Gateway_timestamp` and forwards the data to the `Converter` SNS topic. The `SNS` service acts as a fault-tolerant data bus, where the `Converter` topic triggers a Lambda function to further format the telemetry and submit it to the `Archiver` topic. The `Archiver` topic Lambda function then archives the telemetry data to S3 based on the `data_type` field: `logs` are saved in the immutable S3 bucket, and `metrics` in the mutable S3 bucket.

## Resources

1. **API Gateway**: Acts as the entry point for telemetry data, allowing secure and reliable ingestion of data into the AWS environment.

2. **SNS Service**: Serves as a fault-tolerant data bus with two topics:
    - **Converter Topic**: Receives telemetry data from the API Gateway Lambda function, triggers the Converter Lambda function to format the data, and then forwards it to the Archiver topic.
    - **Archiver Topic**: Receives formatted telemetry data from the Converter Lambda function and triggers the Archiver Lambda function, which archives the data in S3.

3. **S3 Buckets**: Two S3 buckets are used for data storage:
    - **Mutable Bucket**: Stores telemetry data classified as metrics.
    - **Immutable Bucket**: Stores telemetry data classified as logs with object lock enabled for tamper-proof storage.

4. **Lambda Functions**: Three Lambda functions are deployed:
    - **API Gateway Lambda**: Processes telemetry data, adds a timestamp, and forwards it to the `Converter` SNS topic.
    - **Converter Lambda**: Formats the telemetry data, adds another timestamp, and sends it to the `Archiver` SNS topic.
    - **Archiver Lambda**: Reads the `data_type` field in telemetry data and archives logs to the immutable S3 bucket and metrics to the mutable S3 bucket.

## Folder Structure

- **`api_gateway.tf`**: Defines the API Gateway, including its configuration and integration with the API Gateway Lambda function.
- **`api_gateway_lambda.tf`**: Configures the Lambda function triggered by the API Gateway, including the function code, IAM roles, and necessary permissions. This function adds the `RG_GOV_IMS_API_Gateway_timestamp` to telemetry data and forwards it to the Converter SNS topic.
- **`api_gateway_lambda.zip`**: Contains the packaged code for the API Gateway Lambda function.
- **`sns.tf`**: Defines the SNS service with two topics: `Converter` and `Archiver`.
- **`converter_lambda.tf`**: Configures the Lambda function triggered by the Converter SNS topic, which adds a timestamp and forwards telemetry data to the Archiver topic.
- **`converter_lambda.zip`**: Contains the packaged code for the Converter Lambda function.
- **`archiver_lambda.tf`**: Configures the Lambda function triggered by the Archiver SNS topic. This function checks the `data_type` field and archives logs to the immutable S3 bucket and metrics to the mutable S3 bucket.
- **`archiver_lambda.zip`**: Contains the packaged code for the Archiver Lambda function.
- **`s3_mutable.tf`**: Configures the S3 bucket for mutable storage (metrics) without object lock.
- **`s3_immutable.tf`**: Configures the S3 bucket for immutable storage (logs) with object lock enabled.
- **`variables.tf`**: Contains input variables for the Terraform configuration, making it flexible for different environments.
- **`outputs.tf`**: Specifies outputs from the Terraform deployment, such as API Gateway endpoint URLs, SNS ARNs, and S3 bucket names.

## Prerequisites

Before deploying this infrastructure, ensure you have the following:

1. **Terraform**: Installed and configured with AWS credentials.
2. **AWS Account**: Permissions to create API Gateway, Lambda, SNS, and S3 resources.

## Deployment Instructions

1. **Navigate to the `AWS-RG-GOV-IMS` directory**:
   ```bash
   cd path/to/AWS-RG-GOV-IMS
   
2. **Initialize Terraform**: This command downloads the necessary provider plugins.
   ```bash
   terraform init
   
3. **Review and Adjust Variables**: Open `variables.tf` and set any environment-specific variables, such as the AWS region, Lambda function names, API Gateway stage name, and S3 bucket names.

4. **Apply the Configuration**: Deploy the resources to your AWS account. Review the plan and approve the changes.
   ```bash
   terraform apply

## Notes
**IAM Permissions**: The Lambda functions require IAM roles with permissions to interact with SNS, API Gateway, S3, and CloudWatch for logging.

**Testing**: To verify the deployment, use the API Gateway endpoint URL to send telemetry data. Check the SNS topics, S3 buckets, and CloudWatch logs to confirm that the data flows through each Lambda function and is correctly archived based on the data_type field.