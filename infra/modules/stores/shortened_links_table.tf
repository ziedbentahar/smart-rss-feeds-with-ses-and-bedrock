resource "aws_dynamodb_table" "shorted_links_table" {
  name         = "${var.application}-${var.environment}-shortened-links"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "shortenedLinkId"

  attribute {
    name = "shortenedLinkId"
    type = "S"
  }


}
