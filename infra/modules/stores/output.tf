output "newsletter_feeds_table" {
  value = {
    arn  = aws_dynamodb_table.newsletter_feeds.arn
    name = aws_dynamodb_table.newsletter_feeds.name
  }
}


output "shorted_links_table" {
  value = {
    arn  = aws_dynamodb_table.shorted_links_table.arn
    name = aws_dynamodb_table.shorted_links_table.name
  }
}



output "feed_config_table" {
  value = {
    arn              = aws_dynamodb_table.feed_config.arn
    name             = aws_dynamodb_table.feed_config.name
    sender_email_gsi = local.feed_config_sender_email_gsi
  }
}
