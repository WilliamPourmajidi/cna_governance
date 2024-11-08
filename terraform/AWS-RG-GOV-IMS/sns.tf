# Define the SNS Converter Topic
resource "aws_sns_topic" "converter_topic" {
  name = var.sns_converter_topic_name
}

# Define the SNS Archiver Topic
resource "aws_sns_topic" "archiver_topic" {
  name = var.sns_archiver_topic_name
}

# Permissions for SNS Topics (Optional, if needed for cross-account access)
# Uncomment if you need to allow specific IAM roles or external accounts to publish to these topics
# resource "aws_sns_topic_policy" "converter_topic_policy" {
#   arn = aws_sns_topic.converter_topic.arn
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Principal": "*",
#         "Action": "sns:Publish",
#         "Resource": aws_sns_topic.converter_topic.arn
#       }
#     ]
#   })
# }

# resource "aws_sns_topic_policy" "archiver_topic_policy" {
#   arn = aws_sns_topic.archiver_topic.arn
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Principal": "*",
#         "Action": "sns:Publish",
#         "Resource": aws_sns_topic.archiver_topic.arn
#       }
#     ]
#   })
# }
