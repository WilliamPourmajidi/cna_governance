# AWS-RG-1 Terraform Configuration

This folder contains Terraform configurations for deploying resources in the `AWS-RG-1` resource group. The resources include an `AWS API Gateway` integrated with a Lambda function and an `AWS SQS` queue with another Lambda function attached.

This setup facilitates the ingestion of telemetry data through the API Gateway. The affiliated Lambda function adds the `RG_1_API_Gateway_timestamp` field in the `timestamps` element of the telemetry data and forwards it to the `AWS SQS`, which acts as a data bus. Upon receiving the telemetry data, the `AWS SQS` adds its own timestamp, `RG_1_SQS_Forwarder_timestamp`, and forwards the telemetry data to the `AWS API Gateway` located in `RG-GOV-IMS`.

## Resources

1. **API Gateway**: Acts as the entry point for telemetry data, allowing secure access to the AWS environment.

2. **SQS Queue**: The `RG-1-Telemetry-Queue-US-East` SQS queue stores telemetry data messages processed by the first Lambda function, which are then forwarded to the API Gateway in `RG-GOV-IMS`.

3. **Lambda Functions**: Two Lambda functions are deployed:
   - The first function is triggered by the API Gateway to process incoming telemetry data and add a timestamp.
   - The second function is triggered by the SQS queue to add another timestamp and forward the data.


## Folder Structure

- **`api_gateway.tf`**: Defines the API Gateway, including its configuration and integration with the API Gateway Lambda function.
- **`api_gateway_lambda.tf`**: Configures the Lambda function triggered by the API Gateway, including the function code, IAM roles, and necessary permissions. This function adds the `RG_1_API_Gateway_timestamp` to telemetry data and forwards it to the SQS queue.
- **`api_gateway_lambda.zip`**: Contains the packaged code for the API Gateway Lambda function.
- **`sqs.tf`**: Defines the SQS queue named `RG-1-Telemetry-Queue-US-East`, which acts as a data bus for telemetry data.
- **`sqs_lambda.tf`**: Configures the Lambda function triggered by the SQS queue. This function adds the `RG_1_SQS_Forwarder_timestamp` to telemetry data and forwards it to the API Gateway in `RG-GOV-IMS`.
- **`sqs_lambda.zip`**: Contains the packaged code for the SQS Lambda function.
- **`variables.tf`**: Contains input variables for the Terraform configuration, making it flexible for different environments.

## Prerequisites

Before deploying this infrastructure, ensure you have the following:

1. **Terraform**: Installed and configured with AWS credentials.
2. **AWS Account**: Permissions to create API Gateway, Lambda, and SQS resources.

## Deployment Instructions

1. **Navigate to the `AWS-RG-1` directory**:
   ```bash
   cd path/to/AWS-RG-1

2. **Initialize Terraform**: This command downloads the necessary provider plugins.
   ```bash
   terraform init

3. **Review and Adjust Variables**: Open `variables.tf`and set any environment-specific variables, such as the AWS region, Lambda function names,  API Gateway stage name.
4. **Apply the Configuration**: Deploy the resources to your AWS account. Review the plan and approve the changes.
   ```bash
   terraform apply
5. **Review Outputs**: Once deployed, review the output to get information such as the API Gateway URL, Lambda ARNs, and SQS Queue ARN.

## Notes
**IAM Permissions**: The Lambda functions require IAM roles with permissions to interact with SQS, API Gateway, and CloudWatch for logging.

**Testing**: To verify the deployment, you can use the API Gateway endpoint URL to send telemetry data. Check the SQS queue and API Gateway logs to confirm that the data is processed correctly by each Lambda function.
