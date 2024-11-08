# Immutable S3 Bucket for Logs Data with Object Lock Enabled
resource "aws_s3_bucket" "immutable_bucket" {
  bucket = var.s3_immutable_bucket_name

  # Enable Object Lock at bucket creation
  object_lock_enabled = true


  tags = {
    Name        = "RG-GOV-IMS Immutable S3 Bucket"
    Environment = "production"
    DataType    = "logs"
  }
}

# Configure Object Lock Settings for Immutable Storage
resource "aws_s3_bucket_object_lock_configuration" "immutable_bucket_lock" {
  bucket = aws_s3_bucket.immutable_bucket.bucket

  rule {
    default_retention {
      mode = "GOVERNANCE"  # Can also be "COMPLIANCE" based on requirements
      days = 365           # Retain objects for 1 year by default
    }
  }
}

# S3 Bucket Policy (Optional) - restrict access as needed
resource "aws_s3_bucket_policy" "immutable_bucket_policy" {
  bucket = aws_s3_bucket.immutable_bucket.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.immutable_bucket.arn}/*"
      }
    ]
  })
}
