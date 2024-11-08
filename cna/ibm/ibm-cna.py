"""
IBM CNA Telemetry Application

This Python program is designed to simulate a Cloud-Native Application (CNA) that generates telemetry data such as
CPU, memory, disk, and network usage. The application emits telemetry at a configurable interval (currently set to
1 submission per second) and submits it to an API Gateway.

Setup:
- Set the telemetry submission URL (API Gateway) and intervals in the environment variables.

Functionality:
- Collects system metrics and application logs.
- Submits telemetry data to a specified API Gateway for governance processing.
"""

import psutil
import datetime
import time
import uuid
import requests
import logging
import os
import json

# Setup JSON logging
logger = logging.getLogger(__name__)
logHandler = logging.StreamHandler()
logHandler.setFormatter(logging.Formatter('%(message)s'))
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

def create_telemetry_entry(service_name, data_type, governance_data, timestamps, log_id, csp, error=None, api_response=None):
    """
    Creates a structured telemetry entry in JSON format.

    Args:
        service_name (str): Name of the service generating the telemetry.
        data_type (str): Type of data being transmitted (e.g., 'metrics', 'logs').
        governance_data (dict): A dictionary containing the telemetry data or logs.
        timestamps (dict): A dictionary containing timestamps at different stages.
        log_id (str): Unique identifier for the log entry.
        csp (str): Cloud Service Provider (e.g., 'IBM').
        error (str, optional): Error message, if any.
        api_response (str, optional): API response message, if any.
    """
    log_entry = {
        "log_id": log_id,
        "service_name": service_name,
        "data_type": data_type,
        "governance_data": governance_data,
        "timestamps": timestamps,
        "CSP": csp,
        "error": error,
        "api_response": api_response
    }
    logger.info(json.dumps(log_entry))

def log_initial_parameters():
    """
    Retrieves environment variables and logs the initial parameters when the application starts.

    Returns:
        tuple: API Gateway URL and submission intervals in seconds.
    """
    #The following API gateway is located at RG-GOV-IMS
    api_gateway_url = os.getenv('API_GATEWAY_URL')  # make sure to add your API Gateway URL as an environment variable
    metrics_interval_sec = int(os.getenv('METRICS_INTERVAL_SEC', 1))  # Default to 1 second intervals
    logs_interval_sec = int(os.getenv('LOGS_INTERVAL_SEC', 1))  # Default to 1 second intervals

    if not api_gateway_url:
        raise ValueError("No API_GATEWAY_URL set for the environment")

    masked_url = api_gateway_url[-10:]  # Show only the last few characters for security
    initial_message = f"""
    CNA Governance Logger initiated....
    Sending logs to API URL (last few characters): ...{masked_url}
    Metrics interval: {metrics_interval_sec} seconds
    Logs interval: {logs_interval_sec} seconds
    """
    print(initial_message)  # Print to console for immediate visibility
    log_entry = {
        "log_id": str(uuid.uuid4()),
        "service_name": "cna-app",
        "data_type": "initialization",
        "governance_data": None,
        "timestamps": {
            "initial_timestamp": datetime.datetime.now().isoformat()
        },
        "CSP": "IBM",
        "error": None
    }
    logger.info(json.dumps(log_entry))

    return api_gateway_url, metrics_interval_sec, logs_interval_sec

# Log the initial parameters and retrieve the environment variables
api_gateway_url, metrics_interval_sec, logs_interval_sec = log_initial_parameters()

def get_system_metrics():
    """
    Collects system metrics such as memory usage, CPU usage, disk usage, and network I/O.

    Returns:
        dict: A dictionary with system metrics.
    """
    try:
        memory_usage = psutil.virtual_memory().percent
        cpu_usage = psutil.cpu_percent(interval=1)
        disk_usage = psutil.disk_usage('/').percent
        net_io = psutil.net_io_counters()
        bytes_sent = net_io.bytes_sent
        bytes_recv = net_io.bytes_recv

        # Add additional metrics if needed
        additional_metric_1 = "value_1"
        additional_metric_2 = "value_2"

        return {
            'memory_usage': memory_usage,
            'cpu_usage': cpu_usage,
            'disk_usage': disk_usage,
            'bytes_sent': bytes_sent,
            'bytes_recv': bytes_recv,
            'additional_metric_1': additional_metric_1,
            'additional_metric_2': additional_metric_2
        }
    except Exception as e:
        print(f"Error collecting system metrics: {str(e)}")
        raise

def get_application_logs():
    """
    Generates detailed application logs.

    Returns:
        dict: A dictionary with application logs.
    """
    logs = {
        "log_1": "Application started successfully.",
        "log_2": "Collecting system metrics.",
        "log_3": "Metrics collected successfully.",
        "log_4": "Sending data to API Gateway.",
        "log_5": "Data sent successfully.",
        "log_6": "Error handling and logging mechanism operational.",
        "log_7": "System monitoring and logging active.",
        "log_8": "Routine check completed successfully.",
        "log_9": "No errors detected in the last cycle.",
        "log_10": "All systems functional."
    }
    return logs

def send_data_to_api(data_type):
    """
    Sends collected system metrics or logs to the configured API Gateway URL.

    Args:
        data_type (str): The type of data being sent (e.g., 'metrics', 'logs').
    """
    try:
        if data_type == 'metrics':
            governance_data = get_system_metrics()
        elif data_type == 'logs':
            governance_data = get_application_logs()

        payload = {
            'log_id': str(uuid.uuid4()),
            'service_name': 'cna-app',
            'data_type': data_type,
            'governance_data': governance_data,
            'timestamps': {
                'cna_timestamp': datetime.datetime.now(datetime.timezone.utc).isoformat()
            },
            'CSP': 'IBM',
            'error': None
        }

        headers = {'Content-Type': 'application/json'}

        response = requests.post(api_gateway_url, json=payload, headers=headers)
        response.raise_for_status()

        # Log the successful submission locally
        create_telemetry_entry(
            service_name="cna-app",
            data_type=data_type,
            governance_data=payload['governance_data'],
            timestamps=payload['timestamps'],
            log_id=payload['log_id'],
            csp='IBM',
            error=None,
            api_response=response.text
        )

        # Print success message to terminal
        print(f"Successfully submitted {data_type} data: {payload}")

    except requests.exceptions.RequestException as e:
        # Log the failure with the reason locally
        payload['error'] = str(e)
        create_telemetry_entry(
            service_name="cna-app",
            data_type=data_type,
            governance_data=payload.get('governance_data', {}),
            timestamps=payload['timestamps'],
            log_id=payload['log_id'],
            csp='IBM',
            error=str(e),
            api_response=None
        )

        # Print error message to terminal
        print(f"Failed to send {data_type} data: {payload['error']}")

if __name__ == "__main__":
    last_metrics_time = 0
    last_logs_time = 0

    while True:
        current_time = time.time()

        if current_time - last_metrics_time >= metrics_interval_sec:
            send_data_to_api('metrics')
            last_metrics_time = current_time

        if current_time - last_logs_time >= logs_interval_sec:
            send_data_to_api('logs')
            last_logs_time = current_time

        time.sleep(1)
