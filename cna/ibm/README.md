# IBM Cloud-Native Application (CNA)

This folder contains the IBM-specific Cloud-Native Application (CNA), developed in Python to generate and emit telemetry data and application logs every second. The application is containerized using Docker, allowing deployment on IBM Cloud with IBM Cloud Container Registry (ICR) and IBM Kubernetes Service (IKS).

## Contents

- **Dockerfile**: Defines the containerization instructions for building the CNA image.
- **ibm-cna.py**: The primary Python script responsible for generating telemetry and log data.
- **requirements.txt**: Lists the dependencies required by `ibm-cna.py`.

## Prerequisites

Before proceeding, ensure you have the following:

1. **IBM Cloud Account**: An IBM Cloud account with access to ICR and IKS.
2. **IBM Cloud CLI**: The IBM Cloud Command Line Interface configured with appropriate IAM permissions.
3. **Docker**: Installed and running on your local environment to build and push container images.
4. **Python**: Installed to verify dependencies locally if needed. We used Python 3.12.3 for this CNA.

## Important Pre-Containerization Step

Before containerizing the application, practitioners and adopters of this reference architecture need to set up an environment variable named `API_GATEWAY_URL`. This variable should contain the URL for your API Gateway, which is the component responsible for accepting data from the CNA.

In your `ibm-cna.py` script, this environment variable is accessed as follows:

```python
api_gateway_url = os.getenv('API_GATEWAY_URL') 
```
 
## Setup and Deployment Steps

### 1. Containerization with Docker

Build the Docker image for the IBM CNA using the `Dockerfile`.

- **Navigate** to the directory containing the `Dockerfile` and use the Dockerfile to build an image:

  ```bash
  cd path/to/ibm
  docker build -t ibm-cna .
  ```
  
### 2. Push the Image to the IBM Cloud Container Registry
To deploy the Docker container on IBM Cloud, push the image to IBM Cloud Container Registry.

- **Log in** to IBM Cloud CLI and target the appropriate region:

  ```bash
  ibmcloud login -r <region>
  ```
  

- **Create** an IBM Cloud Container Registry namespace (only needed once):

  ```bash
  ibmcloud cr namespace-add <namespace>
  ```


- **Tag** the Docker image with the IBM Cloud Container Registry:

  ```bash  
  docker tag ibm-cna:latest <region>.icr.io/<namespace>/ibm-cna:latest
  cna:latest
  ```  

- **Push** the image to IBM Cloud Container Registry:

  ```bash 
  docker push <region>.icr.io/<namespace>/ibm-cna:latest
  ```

### 3. Deploy the CNA Image on the IBM Kubernetes Service
Once the image is in the IBM Cloud Container Registry, you can  set up an IBM Kubernetes Service cluster to run the container.

- **Create** an IBM Kubernetes Service Cluster (if not already created):

  ```bash 
  ibmcloud ks cluster-create --name ibm-cna-cluster --zone <zone>
  ```


- **Set** the Kubernetes context to use your IBM Kubernetes Service cluster:

  ```bash 
  ibmcloud ks cluster-config --cluster ibm-cna-cluster
  export KUBECONFIG=~/.bluemix/plugins/container-service/clusters/ibm-cna-cluster/kube-config-mil01-ibm-cna-cluster.yml
  ```

- **Create** a Kubernetes Deployment for the IBM CNA. Save the following YAML configuration as `ibm-cna-deployment.yaml`, and replace `<region>` and `<namespace>` with your values. Make sure to replace `<your_api_gateway_url>`  with your API gateway URL. Last but not least, adjust `CPU` and `memory` as needed:

  
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: ibm-cna-deployment
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: ibm-cna
    template:
      metadata:
        labels:
          app: ibm-cna
      spec:
        containers:
        - name: ibm-cna-container
          image: <region>.icr.io/<namespace>/ibm-cna:latest
          resources:
            limits:
              memory: "512Mi"
              cpu: "500m"
          env:
          - name: API_GATEWAY_URL
            value: "<your_api_gateway_url>"
  ```



- **Apply** the deployment to your IBM Kubernetes Service cluster:

  ```bash 
  kubectl apply -f ibm-cna-deployment.yaml
  ```

### 4. Monitoring and Logging
To **view** logs for the IBM CNA, use the following command:

  ```bash 
  kubectl logs -l app=ibm-cna
  
  ```
