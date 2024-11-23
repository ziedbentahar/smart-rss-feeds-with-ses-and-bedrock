resource "aws_s3_bucket" "email_bucket" {
  bucket = "${var.application}-${var.environment}"

  force_destroy = true
}

resource "aws_s3_bucket_policy" "email_bucket_policy" {
  bucket = aws_s3_bucket.email_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ses.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.email_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "aws:Referer" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
