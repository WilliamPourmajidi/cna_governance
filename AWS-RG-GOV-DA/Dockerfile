# Use an official Python runtime as a parent image
FROM python:3.12.3-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file to the container
COPY requirements.txt .

# Install any dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code to the container
COPY rg-gov-da-time-response-analysis.py .
COPY time_diffs_observations.csv .
COPY time_diffs_statistics.csv .

# Set environment variables if needed
ENV IMMUTABLE_BUCKET_NAME=<your_immutable_bucket_name>
ENV MUTABLE_BUCKET_NAME=<your_mutable_bucket_name>

# Command to run the analytics application
CMD ["python", "./rg-gov-da-time-response-analysis.py"]
