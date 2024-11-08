# Define the SQS Queue for telemetry data
resource "aws_sqs_queue" "rg1_telemetry_queue" {
  name                       = "RG-1-Telemetry-Queue-US-East"
  message_retention_seconds  = 86400   # Retain messages for 1 day
  visibility_timeout_seconds = 30      # Timeout for processing a single message

  # Optional: Uncomment and configure dead-letter queue settings if required
  # redrive_policy = jsonencode({
  #   deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
  #   maxReceiveCount     = 5
  # })
}
