# Terraform Configuration for Multi-Cloud CNA Governance Platform

This folder contains Terraform configurations to deploy resources for the multi-cloud CNA Governance Platform on AWS. The resources are organized into two main resource groups, each designed to facilitate specific functionalities within the architecture.

## Folder Structure

- **`AWS-RG-1/`**: Contains Terraform files to deploy resources in AWS Resource Group 1, including an API Gateway, SQS queue, and associated Lambda functions. This group handles initial ingestion and forwarding of telemetry data.

- **`AWS-RG-GOV-IMS/`**: Contains Terraform files for deploying resources in AWS Resource Group GOV-IMS, which includes another API Gateway, SNS topics (Converter and Archiver), Lambda functions, and S3 storage (both mutable and immutable) for archiving telemetry data based on data type.

## Prerequisites

Before deploying these resources, ensure you have the following:

1. **Terraform**: Installed and configured with AWS credentials. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) if it’s not already installed.
2. **AWS Account**: Permissions to create API Gateway, Lambda, SNS, SQS, and S3 resources in the specified AWS regions.

