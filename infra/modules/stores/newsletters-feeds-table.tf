resource "aws_dynamodb_table" "newsletter_feeds" {
  name         = "${var.application}-${var.environment}-newsletters-feeds"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "feedId"
  range_key    = "date"

  attribute {
    name = "feedId"
    type = "S"
  }

  attribute {
    name = "date"
    type = "S"
  }
}
