resource "aws_s3_bucket" "email_bucket" {
  bucket = "${var.application}-${var.environment}"

  force_destroy = true
}

