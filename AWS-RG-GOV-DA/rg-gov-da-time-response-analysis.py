import boto3
import json
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import logging

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# S3 bucket names
immutable_bucket_name = 'rg-gov-ims-telemetry-archive-immutable-us-east'

# Initialize the S3 client
s3_client = boto3.client('s3')


def load_json_files_from_s3(bucket_name, prefix):
    """
    Load all JSON files from the specified S3 bucket with a given prefix (e.g., 'aws-' or 'ibm-').

    Args:
    - bucket_name (str): The name of the S3 bucket.
    - prefix (str): The prefix to filter files (e.g., 'aws-' or 'ibm-').

    Returns:
    - list: A list of loaded JSON content from the files.
    """
    logging.info(f"Loading JSON files with prefix '{prefix}' from S3 bucket: {bucket_name}")
    json_data = []
    paginator = s3_client.get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(Bucket=bucket_name, Prefix=prefix)

    for page in page_iterator:
        if 'Contents' in page:
            for obj in page['Contents']:
                key = obj['Key']
                if key.endswith(".json"):
                    response = s3_client.get_object(Bucket=bucket_name, Key=key)
                    json_content = json.loads(response['Body'].read().decode('utf-8'))
                    json_data.append(json_content)

    logging.info(f"Loaded {len(json_data)} JSON files with prefix '{prefix}' from {bucket_name}")
    return json_data


def calculate_aws_time_diffs(json_data):
    """
    Calculate time differences for AWS (5 legs).

    Args:
    - json_data (list): List of JSON data loaded from files.

    Returns:
    - pd.DataFrame: A DataFrame containing time differences for each leg.
    """
    time_diffs = []

    for item in json_data:
        timestamps = item.get('timestamps', {})
        cna_timestamp = timestamps.get('cna_timestamp')

        rg_1_api_gateway_timestamp = timestamps.get('RG_1_API_Gateway_timestamp')
        rg_1_sqs_forwarder_timestamp = timestamps.get('RG_1_SQS_Forwarder_timestamp')
        rg_gov_ims_api_gateway_timestamp = timestamps.get('RG_GOV_IMS_API_Gateway_timestamp')
        rg_gov_ims_converter_timestamp = timestamps.get('RG_GOV_IMS_Converter_timestamp')
        rg_gov_ims_archiver_timestamp = timestamps.get('RG_GOV_IMS_Archiver_timestamp')

        # Calculate delays for each leg
        leg1 = (pd.to_datetime(rg_1_api_gateway_timestamp) - pd.to_datetime(cna_timestamp)).total_seconds() * 1000 if cna_timestamp and rg_1_api_gateway_timestamp else None
        leg2 = (pd.to_datetime(rg_1_sqs_forwarder_timestamp) - pd.to_datetime(rg_1_api_gateway_timestamp)).total_seconds() * 1000 if rg_1_api_gateway_timestamp and rg_1_sqs_forwarder_timestamp else None
        leg3 = (pd.to_datetime(rg_gov_ims_api_gateway_timestamp) - pd.to_datetime(rg_1_sqs_forwarder_timestamp)).total_seconds() * 1000 if rg_1_sqs_forwarder_timestamp and rg_gov_ims_api_gateway_timestamp else None
        leg4 = (pd.to_datetime(rg_gov_ims_converter_timestamp) - pd.to_datetime(rg_gov_ims_api_gateway_timestamp)).total_seconds() * 1000 if rg_gov_ims_api_gateway_timestamp and rg_gov_ims_converter_timestamp else None
        leg5 = (pd.to_datetime(rg_gov_ims_archiver_timestamp) - pd.to_datetime(rg_gov_ims_converter_timestamp)).total_seconds() * 1000 if rg_gov_ims_converter_timestamp and rg_gov_ims_archiver_timestamp else None

        time_diffs.append({
            'CSP': 'AWS',
            'Leg 1': leg1,
            'Leg 2': leg2,
            'Leg 3': leg3,
            'Leg 4': leg4,
            'Leg 5': leg5,
        })

    return pd.DataFrame(time_diffs)


def calculate_ibm_time_diffs(json_data):
    """
    Calculate time differences for IBM (Legs 1, 4, and 5).

    Args:
    - json_data (list): List of JSON data loaded from files.

    Returns:
    - pd.DataFrame: A DataFrame containing time differences for each leg.
    """
    time_diffs = []

    for item in json_data:
        timestamps = item.get('timestamps', {})
        cna_timestamp = timestamps.get('cna_timestamp')

        rg_gov_ims_api_gateway_timestamp = timestamps.get('RG_GOV_IMS_API_Gateway_timestamp')
        rg_gov_ims_converter_timestamp = timestamps.get('RG_GOV_IMS_Converter_timestamp')
        rg_gov_ims_archiver_timestamp = timestamps.get('RG_GOV_IMS_Archiver_timestamp')

        # Calculate delays for each leg
        leg1 = (pd.to_datetime(rg_gov_ims_api_gateway_timestamp) - pd.to_datetime(cna_timestamp)).total_seconds() * 1000 if cna_timestamp and rg_gov_ims_api_gateway_timestamp else None
        leg4 = (pd.to_datetime(rg_gov_ims_converter_timestamp) - pd.to_datetime(rg_gov_ims_api_gateway_timestamp)).total_seconds() * 1000 if rg_gov_ims_api_gateway_timestamp and rg_gov_ims_converter_timestamp else None
        leg5 = (pd.to_datetime(rg_gov_ims_archiver_timestamp) - pd.to_datetime(rg_gov_ims_converter_timestamp)).total_seconds() * 1000 if rg_gov_ims_converter_timestamp and rg_gov_ims_archiver_timestamp else None

        time_diffs.append({
            'CSP': 'IBM',
            'Leg 1': leg1,
            'Leg 2': None,  # IBM does not have Leg 2
            'Leg 3': None,  # IBM does not have Leg 3
            'Leg 4': leg4,
            'Leg 5': leg5,
        })

    return pd.DataFrame(time_diffs)


# Step 1: Load the JSON files from S3
aws_json = load_json_files_from_s3(immutable_bucket_name, 'aws-')
ibm_json = load_json_files_from_s3(immutable_bucket_name, 'ibm-')

# Step 2: Calculate time differences for AWS and IBM
aws_time_diffs = calculate_aws_time_diffs(aws_json)
ibm_time_diffs = calculate_ibm_time_diffs(ibm_json)

# Step 3: Combine the data into a single DataFrame for analysis
df_time_diffs = pd.concat([aws_time_diffs, ibm_time_diffs], axis=0, ignore_index=True)

# Step 4: Save all observations to a CSV file
df_time_diffs.to_csv('time_diffs_observations.csv', index=False)
logging.info("All observations have been saved to 'time_diffs_observations.csv'.")

# Step 5: Generate statistical analysis for each leg
stats = df_time_diffs.groupby('CSP').agg(['mean', 'median', 'std', 'min', 'max'])

# Step 6: Save statistics to a CSV file for use in reports or visualization later
stats.to_csv('time_diffs_statistics.csv')
logging.info("Statistics have been saved to 'time_diffs_statistics.csv'.")

# Visualization Part
logging.info("Generating the time delay graph.")

# Step 7: Reshape the data for plotting
df_long = pd.melt(df_time_diffs, id_vars=['CSP'], value_vars=['Leg 1', 'Leg 2', 'Leg 3', 'Leg 4', 'Leg 5'],
                  var_name='Leg', value_name='Time')

# Step 8: Set up Seaborn and Matplotlib styles
sns.set(style="whitegrid")

# Step 9: Create a facet grid with two rows:
# - First row will have Leg 1 and Leg 2
# - Second row will have Leg 3, Leg 4, and Leg 5
g = sns.FacetGrid(df_long, col='Leg', col_wrap=2, height=4, aspect=1.2)

# Step 10: Map boxplots to the FacetGrid
g.map_dataframe(sns.boxplot, x='CSP', y='Time', hue='CSP', palette='Set2')

# Step 11: Apply log scale to the y-axis for each subplot and add logical ticks
for ax in g.axes.flat:
    ax.set_yscale('log')
    y_ticks = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
    ax.set_yticks(y_ticks)
    ax.set_yticklabels([f"{int(tick)} ms" for tick in y_ticks])

# Step 12: Add proper axis labels, titles, and adjust legend
g.set_axis_labels("CSP (Cloud Service Provider)", "Time Delay (log-scale, milliseconds)")
g.set_titles(col_template="{col_name}")
g.fig.suptitle("Box Plot: Log-Scaled Time Delay Comparison Across Legs for AWS and IBM", y=1.02, fontsize=12, fontweight='bold')

# Step 13: Adjust and enhance the legend
g.add_legend(title="Cloud Service Provider", loc="upper center", bbox_to_anchor=(0.5, -0.1), ncol=2, fontsize=12, title_fontsize=13)

# Step 14: Use subplots_adjust to properly place title and legend
plt.subplots_adjust(top=0.85, bottom=0.15)

# Step 15: Save the plot and display
plt.savefig('time_delay_plot.png')
logging.info("Time delay graph has been saved to 'time_delay_plot.png'.")
plt.show()
