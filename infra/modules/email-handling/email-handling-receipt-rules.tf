resource "aws_ses_receipt_rule_set" "this" {
  rule_set_name = "${var.application}-${var.environment}-newsletter-rule-set"
}

resource "aws_ses_receipt_rule" "this" {
  name          = "${var.application}-${var.environment}-to-bucket"
  rule_set_name = aws_ses_receipt_rule_set.this.rule_set_name
  recipients    = ["${local.email_subdomain}"]
  enabled       = true
  scan_enabled  = true

  s3_action {
    position          = 1
    bucket_name       = var.bucket.id
    object_key_prefix = local.emails_prefix
  }

  depends_on = [
    aws_ses_receipt_rule_set.this,
    aws_s3_bucket_policy.email_bucket_policy
  ]
}

resource "aws_ses_active_receipt_rule_set" "this" {
  rule_set_name = aws_ses_receipt_rule_set.this.rule_set_name
  depends_on    = [aws_ses_receipt_rule_set.this]
}

