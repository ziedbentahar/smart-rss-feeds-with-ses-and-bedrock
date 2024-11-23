data "aws_route53_zone" "root" {
  name = "${var.domain}."
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
