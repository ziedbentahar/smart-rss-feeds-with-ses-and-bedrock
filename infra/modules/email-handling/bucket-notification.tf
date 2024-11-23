resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.email_bucket.id
  eventbridge = true
}







