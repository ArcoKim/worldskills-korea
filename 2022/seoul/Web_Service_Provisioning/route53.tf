resource "aws_route53_zone" "main" {
  name = "service.internal"

  vpc {
    vpc_id = aws_vpc.vpc_a.id
  }

  vpc {
    vpc_id = aws_vpc.vpc_b.id
  }
}

resource "aws_route53_record" "web" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "service.internal"
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}