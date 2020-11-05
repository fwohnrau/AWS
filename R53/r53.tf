resource "aws_route53_zone" "ecommerce_main" {
  name = var.domaine_name
}

resource "aws_route53_zone" "dev" {
  name = join("", [var.environment,"-", var.domaine_name])

  tags = {
    Environment = "dev"
  }
}

resource "aws_route53_record" "r53_record" {
  zone_id = aws_route53_zone.dev.zone_id
  name    = aws_route53_zone.dev.name
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.dev.name_servers
}