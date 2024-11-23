resource "aws_lambda_permission" "this" {
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "cloudfront.amazonaws.com"
  action        = "lambda:InvokeFunctionUrl"
  source_arn    = aws_cloudfront_distribution.this.arn
}

data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_origin_access_control" "oac_lambda" {
  name                              = "${var.application}-${var.environment}-api-oac"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}



resource "aws_cloudfront_distribution" "this" {

  origin {
    domain_name              = replace(aws_lambda_function_url.api.function_url, "/https:\\/\\/|\\//", "")
    origin_access_control_id = aws_cloudfront_origin_access_control.oac_lambda.id
    origin_id                = "api"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = [local.api_subdomain]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api"

    cache_policy_id        = data.aws_cloudfront_cache_policy.disabled.id
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0

  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.this.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"

  }

  depends_on = [aws_acm_certificate_validation.cert_validation]
}


