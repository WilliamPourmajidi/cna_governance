# Mutable S3 Bucket for Metrics Data
resource "aws_s3_bucket" "mutable_bucket" {
  bucket = var.s3_mutable_bucket_name


  tags = {
    Name        = "RG-GOV-IMS Mutable S3 Bucket"
    Environment = "production"
    DataType    = "metrics"
  }
}

# S3 Bucket Policy (Optional) - restrict access as needed
resource "aws_s3_bucket_policy" "mutable_bucket_policy" {
  bucket = aws_s3_bucket.mutable_bucket.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.mutable_bucket.arn}/*"
      }
    ]
  })
}
