resource "aws_route53_zone" "subdomain" {
  name = "${var.subdomain}.${data.aws_route53_zone.root.name}"
}

resource "aws_route53_record" "ns" {
  name    = aws_route53_zone.subdomain.name
  records = aws_route53_zone.subdomain.name_servers

  ttl = 300

  type    = "NS"
  zone_id = data.aws_route53_zone.root.zone_id
}

