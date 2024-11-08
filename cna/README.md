# Cloud-Native Applications (CNA) Folder

The `cna` folder contains cloud-native applications specifically developed to run on AWS and IBM Cloud platforms, simulating real-world, high-demand application scenarios. These Cloud-Native Applications (CNAs) are containerized using Docker to enable seamless deployment across multiple cloud platforms, facilitating a multi-cloud deployment strategy.

## Overview of CNA

To replicate a real-world CNA scenario, we developed a Python-based CNA that generates and transmits telemetry data and application logs every second, emulating a high-load application environment. This telemetry includes critical metrics such as CPU usage, memory consumption, disk I/O, and network activity, providing visibility into the application's performance and operational status.

Both AWS and IBM CNA instances are deployed to create a redundant and scalable setup, demonstrating the flow of telemetry data across different cloud environments.

## Multi-Cloud Deployment

We implemented two instances of the CNA:

- **AWS CNA**: Deployed on AWS Cloud within Resource Group RG-1, utilizing AWS services like Elastic Container Registry (ECR) and Elastic Container Service (ECS) for deployment and management.
- **IBM CNA**: Deployed on IBM Cloud within Resource Group RG-1, utilizing IBM Cloud Container Registry (ICR) and IBM Kubernetes Service (IKS) for deployment and management.

This configuration allows us to simulate telemetry flows for the same CNA application deployed across multiple clouds, providing resilience, scalability, and interoperability.

## Data Architecture and Characteristics

Both AWS and IBM CNA implementations share a unified architecture with the following key components:

### Data Types

The CNA continuously generates two types of data:

1. **Telemetry Data**: Includes resource utilization metrics such as CPU, memory, disk, and network usage.
2. **Application Logs**: Captures operational logs detailing the internal processes of the CNA.

### JSON Structure and Tags

All telemetry and logs are submitted in a JSON format inspired by the ZIPKIN tracing model, featuring several structured fields:

- **CSP Tag**: Specifies the Cloud Service Provider (CSP) where the CNA is hosted, with values of either `"IBM"` or `"AWS"`.
- **Data Type Tag**: Identifies the type of data in the `data_type` field, which can be either `"telemetry"` or `"logs"`.
- **Timestamps Tag**: Contains nested JSON with timestamps indicating the generation time of telemetry and logs. Each governance component adds its own timestamp in the `timestamps` field, allowing precise time-delay analysis across the pipeline.
- **Unique ID**: Each telemetry or log entry has a unique identifier, ensuring traceability throughout the governance pipeline. This ID is also utilized by the archiver component to name objects stored in mutable or immutable storage.

## Folder Structure

The `cna` folder is organized as follows to support modularity and maintainability:

- **AWS**: Contains the AWS-specific cloud-native application, with the following files:
  - `Dockerfile`: Builds a container image for the AWS CNA.
  - `aws-cna.py`: Main Python script that generates telemetry and logs.
  - `requirements.txt`: Lists dependencies required to run the AWS CNA.
  - **README.md**: Step-by-step deployment guide for containerization, pushing the image to AWS ECR, and running the image in ECS.

- **IBM**: Contains the IBM-specific cloud-native application, with the following files:
  - `Dockerfile`: Builds a container image for the IBM CNA.
  - `ibm-cna.py`: Main Python script that generates telemetry and logs.
  - `requirements.txt`: Lists dependencies required to run the IBM CNA.
  - **README.md**: Step-by-step deployment guide for containerization, pushing the image to IBM Cloud Container Registry, and running the image in IBM Kubernetes Service.

Each application instance is designed to run independently in its respective containerized environment, offering deployment flexibility and consistency across AWS and IBM Cloud platforms.

## Deployment Process Overview

Both AWS and IBM CNAs require similar steps for deployment, involving containerization with Docker, pushing images to cloud-specific registries, and running the containers in managed services (AWS ECS or IBM IKS). Detailed instructions for each cloud provider can be found in their respective subfolder’s `README.md` file.

### Key Deployment Steps:

1. **Environment Variable Setup**: Set an `API_GATEWAY_URL` environment variable with the URL of the API Gateway that will accept telemetry data.
2. **Containerization**: Build the Docker image for each CNA using the provided `Dockerfile`.
3. **Push to Cloud Registry**:
   - For AWS, push to Elastic Container Registry (ECR).
   - For IBM, push to IBM Cloud Container Registry (ICR).
4. **Run on Cloud Managed Service**:
   - For AWS, deploy the container on Elastic Container Service (ECS).
   - For IBM, deploy the container on IBM Kubernetes Service (IKS).
5. **Monitoring**: View logs in CloudWatch (AWS) or use `kubectl logs` for IBM.

> **Note**: For AWS- and IBM-specific deployment steps, navigate to their respective subfolders and refer to the relevant `README.md` file.

This deployment strategy demonstrates the flexibility and scalability of CNAs in a multi-cloud environment, allowing for high availability and data traceability across cloud providers.
