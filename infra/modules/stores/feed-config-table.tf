locals {
  feed_config_sender_email_gsi = "senderEmail-index"
}

resource "aws_dynamodb_table" "feed_config" {
  name         = "${var.application}-${var.environment}-feed-config"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "feedId"

  global_secondary_index {
    name            = local.feed_config_sender_email_gsi
    hash_key        = "senderEmail"
    projection_type = "ALL"
  }

  attribute {
    name = "feedId"
    type = "S"
  }

  attribute {
    name = "senderEmail"
    type = "S"
  }
}


