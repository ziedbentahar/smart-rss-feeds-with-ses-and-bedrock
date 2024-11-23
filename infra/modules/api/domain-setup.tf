resource "aws_route53_record" "a_record" {
  zone_id = var.subdomain_zone.id
  name    = local.api_subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "aaaa_record" {
  zone_id = var.subdomain_zone.id
  name    = local.api_subdomain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
}
