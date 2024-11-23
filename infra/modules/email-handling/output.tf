output "object_created_event_rule" {
  value = {
    name = aws_cloudwatch_event_rule.this.name
    arn = aws_cloudwatch_event_rule.this.arn
  }
}

output "bucket" {
  value = {
    id = aws_s3_bucket.email_bucket.id
    arn  = aws_s3_bucket.email_bucket.arn
  }
}