# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements.txt file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Set the environment variables
ENV API_GATEWAY_URL='put-your-API-gateway-URL-here'
ENV METRICS_INTERVAL_SEC=1
ENV LOGS_INTERVAL_SEC=1

# Run the application
CMD ["python", "ibm-cna.py"]
