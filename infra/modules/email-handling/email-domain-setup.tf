
resource "aws_ses_domain_identity" "this" {
  domain = local.email_subdomain
}
resource "aws_route53_record" "email_record" {
  zone_id = var.subdomain_zone.id
  name    = "_amzonses.${local.email_subdomain}"
  type    = "TXT"
  ttl     = 600

  records = [
    aws_ses_domain_identity.this.verification_token,
  ]
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}
resource "aws_route53_record" "email_dkim_record" {
  count   = 3
  zone_id = var.subdomain_zone.id
  name    = "${element(aws_ses_domain_dkim.this.dkim_tokens, count.index)}._domainkey.${local.email_subdomain}"
  type    = "CNAME"
  ttl     = 600

  records = [
    "${element(aws_ses_domain_dkim.this.dkim_tokens, count.index)}.dkim.amazonses.com",
  ]
}
resource "aws_route53_record" "email_mx_records" {
  zone_id = var.subdomain_zone.id
  name    = local.email_subdomain
  type    = "MX"
  ttl     = "600"

  records = [
    "10 inbound-smtp.us-east-1.amazonses.com",
    "10 inbound-smtp.us-east-1.amazonaws.com",
  ]
}

resource "aws_route53_record" "spf_records" {
  zone_id = var.subdomain_zone.id
  name    = local.email_subdomain
  type    = "TXT"
  ttl     = "600"

  records = [
    "v=spf1 include:amazonses -all"
  ]
}
