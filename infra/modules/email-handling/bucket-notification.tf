resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.email_bucket.id
  eventbridge = true
}


resource "aws_cloudwatch_event_rule" "this" {
  event_pattern = <<EOF
{
  "detail-type": ["Object Created"],
  "source": ["aws.s3"],
  "detail": {
    "bucket": {
      "name": ["${aws_s3_bucket.email_bucket.id}"]
    },
     "object": {
      "key": [{
        "prefix": "inbox/"
      }]
    }
  }

}
EOF
}




