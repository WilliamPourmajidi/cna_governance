# AWS Data Analytics Sample Application

This folder contains a data analytics application developed in Python. The application retrieves and analyzes telemetry data stored in AWS S3, acting as an example of a pluggable analytics engine within the multi-cloud CNA Governance Platform. The application calculates time differences across different processing legs for telemetry data from AWS and IBM CNAs, providing insights into latency at various stages. It is containerized using Docker for seamless deployment to AWS infrastructure via Elastic Container Registry (ECR) and Elastic Container Service (ECS).


## Folder Structure

- **`readme.md`**: Documentation for setup, deployment, and usage of the analytics application within the `AWS-RG-GOV-DA` module.
- **`Dockerfile`**: Defines the containerization instructions for building the analytics application image.
- **`requirements.txt`**: Lists Python dependencies required by the analytics application.
- **`rg-gov-da-time-response-analysis.py`**: Main Python script responsible for loading data from S3, calculating time delays, and generating statistical analysis for response times.
- **`time_delay_plot.png`**: A generated visualization showing time delay comparisons across different telemetry processing legs for AWS and IBM.
- **`time_diffs_observations.csv`**: CSV file containing observations of time delays for each leg, allowing further data exploration and analysis.
- **`time_diffs_statistics.csv`**: CSV file with statistical summaries (mean, median, standard deviation, etc.) of time delays across telemetry data processing stages.




## Prerequisites

Before proceeding, ensure you have the following:

1. **AWS Account**: An AWS account with access to ECR and ECS.
2. **AWS CLI**: The AWS Command Line Interface configured with appropriate IAM permissions.
3. **Docker**: Installed and running on your local environment to build and push container images.
4. **Python**: Installed to verify dependencies locally if needed. We have used Python 3.12.3 for developing this analytics application.

## Important Pre-Containerization Step

Before containerizing the application, practitioners and adopters of this reference architecture need to set up environment variables for the S3 bucket names:

- `IMMUTABLE_BUCKET_NAME`: The name of the immutable S3 bucket where telemetry data is stored for processing and analysis.

These environment variables are accessed in `analytics_app.py` as follows:

   ```python
   import os
   immutable_bucket_name = os.getenv('IMMUTABLE_BUCKET_NAME')
   ```

## Setup and Deployment Steps

### 1. Containerization with Docker

Build the Docker image for the AWS CNA using the `Dockerfile`.

- **Navigate** to the directory containing the `Dockerfile` and use the Dockerfile to build an image:

  ```bash
  cd path/to/data_analytics
  docker build -t data-analytics-app
  ```


### 2. Push the Image to AWS ECR
To deploy the Docker container on AWS ECS, first push the image to AWS ECR.

- **Create** an ECR repository (only needed once):

    ```bash
    aws ecr create-repository --repository-name data-analytics-app
    ```

- **Authenticate** Docker with the ECR registry:

    ```bash
    aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com
    ```

- **Tag** the Docker image with the ECR repository URI:

  ```bash  
  docker tag data-analytics-app:latest <account_id>.dkr.ecr.<region>.amazonaws.com/data-analytics-app:latest
  ```  

- **Push** the image to ECR:

  ```bash 
  docker push <account_id>.dkr.ecr.<region>.amazonaws.com/data-analytics-app:latest
  ```

### 3. Deploy the Analytics Application on AWS ECS
Once the image is in ECR, set up an ECS task to run the container.

- **Create** an ECS Cluster (if not already created):

    ```bash 
    aws ecs create-cluster --cluster-name data-analytics-cluster
    ```

- **Define** the Task Definition for the ECS task. Save the following JSON as data-analytics-task.json, and replace <account_id> and <region> with your actual values. Adjust the CPU and memory values as necessary.

    ```JSON
    {
      "family": "data-analytics-task",
      "networkMode": "bridge",
      "containerDefinitions": [
        {
          "name": "data-analytics-container",
          "image": "<account_id>.dkr.ecr.<region>.amazonaws.com/data-analytics-app:latest",
          "memory": 512,
          "cpu": 256,
          "essential": true,
          "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": "/ecs/data-analytics-app",
              "awslogs-region": "<region>",
              "awslogs-stream-prefix": "data-analytics"
            }
          },
          "environment": [
            {
              "name": "IMMUTABLE_BUCKET_NAME",
              "value": "<your_s3_bucket_name>"
            }
          ]
        }
      ],
      "requiresCompatibilities": ["EC2"],
      "cpu": "256",
      "memory": "512"
    }
    ```

- **Register** the Task Definition:

    ```bash 
    aws ecs register-task-definition --cli-input-json file://data-analytics-task.json
    ```

- **Run** the ECS Task:

    ```bash 
    aws ecs run-task --cluster data-analytics-cluster --launch-type EC2 --task-definition data-analytics-task
    ```

### 4. Monitoring and Logging
Logs for the data analytics application can be viewed in CloudWatch under the log group /ecs/data-analytics-app with the log stream prefix `data-analytics`.




