resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_alb.main.dns_name
    origin_id   = aws_alb.main.name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = false

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_alb.main.name
    viewer_protocol_policy = "https-only"
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.CachingDisabled
  }

  ordered_cache_behavior {
    path_pattern           = "/about"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_alb.main.name
    viewer_protocol_policy = "https-only"
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.CachingOptimized
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_cloudfront_cache_policy" "CachingOptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "CachingDisabled" {
  name = "Managed-CachingDisabled"
}