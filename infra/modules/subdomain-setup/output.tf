output "subdomain_zone" {
  value = {
    id   = aws_route53_zone.subdomain.zone_id
    name = aws_route53_zone.subdomain.name
  }
}