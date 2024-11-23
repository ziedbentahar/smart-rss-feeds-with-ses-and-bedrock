output "bucket" {
  value = {
    id  = aws_s3_bucket.email_bucket.id
    arn = aws_s3_bucket.email_bucket.arn
  }
}
