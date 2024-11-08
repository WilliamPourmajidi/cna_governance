# AWS Cloud-Native Application (CNA)

This folder contains the AWS-specific Cloud-Native Application (CNA), developed in Python to generate and emit telemetry data and application logs every second. The application is containerized using Docker, allowing deployment on AWS infrastructure with Elastic Container Registry (ECR) and Elastic Container Service (ECS).

## Contents

- **Dockerfile**: Defines the containerization instructions for building the CNA image.
- **aws-cna.py**: The primary Python script responsible for generating telemetry and log data.
- **requirements.txt**: Lists the dependencies required by `aws-cna.py`.

## Prerequisites

Before proceeding, ensure you have the following:

1. **AWS Account**: An AWS account with access to ECR and ECS.
2. **AWS CLI**: The AWS Command Line Interface configured with appropriate IAM permissions.
3. **Docker**: Installed and running on your local environment to build and push container images.
4. **Python**: Installed to verify dependencies locally if needed. We have used Python 3.12.3 as this was the latest version during the development of our CNA.

## Important Pre-Containerization Step

Before containerizing the application, practitioners and adopters of this reference architecture need to set up an environment variable named `API_GATEWAY_URL`. This variable should contain the URL for your API Gateway, which is the component responsible for accepting data from the CNA.

In your `aws-cna.py` script, this environment variable is accessed as follows:

  ```python
  api_gateway_url = os.getenv('API_GATEWAY_URL') 
  ```
 
 
## Setup and Deployment Steps

### 1. Containerization with Docker

Build the Docker image for the AWS CNA using the `Dockerfile`.

- **Navigate** to the directory containing the `Dockerfile` and use the Dockerfile to build an image:

  ```bash
  cd path/to/aws
  docker build -t aws-cna .
  ```
  
  
### 2. Push the Image to AWS ECR
To deploy the Docker container on AWS ECS, first push the image to AWS ECR.

- **Create** an ECR repository (only needed once):
    
    ```bash
    aws ecr create-repository --repository-name aws-cna
    ```

- **Authenticate** Docker with the ECR registry:
  
  ```bash
  aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com
  ```

- **Tag** the Docker image with the ECR repository URI:

  ```bash  
    docker tag aws-cna:latest <account_id>.dkr.ecr.<region>.amazonaws.com/aws-cna:latest
  ```  

- **Push** the image to ECR:

  ```bash 
  docker push <account_id>.dkr.ecr.<region>.amazonaws.com/aws-cna:latest
  ```

### 3. Deploy the CNA Image on AWS ECS
Once the image is in ECR, set up an ECS task to run the container.

- **Create** an ECS Cluster (if not already created):

  ```bash 
  aws ecs create-cluster --cluster-name aws-cna-cluster
  ```

- **Define** the Task Definition for the ECS task. Save the following JSON as `aws-cna-task.json`, and replace `<account_id>` and `<region>` with your actual values. Feel free to adjust the `CPU` and `memory` values based on your container's needs. 

  ```JSON
  {
    "family": "aws-cna-task",
    "networkMode": "bridge",
    "containerDefinitions": [
      {
        "name": "aws-cna-container",
        "image": "<account_id>.dkr.ecr.<region>.amazonaws.com/aws-cna:latest",
        "memory": 512,
        "cpu": 256,
        "essential": true,
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/aws-cna",
            "awslogs-region": "<region>",
            "awslogs-stream-prefix": "aws-cna"
          }
        },
        "environment": [
          {
            "name": "API_GATEWAY_URL",
            "value": "<your_api_gateway_url>"
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
  aws ecs register-task-definition --cli-input-json file://aws-cna-task.json
  ```
 
- **Run** the ECS Task:

  ```bash 
  aws ecs run-task --cluster aws-cna-cluster --launch-type EC2 --task-definition aws-cna-task
  ```

### 4. Monitoring and Logging
Logs for the AWS CNA can be viewed in CloudWatch under the log group `/ecs/aws-cna` with the log stream prefix `aws-cna`.




