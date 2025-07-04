
## pull dns public xzone data
data "aws_route53_zone" "main" {
  name         = var.app_domain
  private_zone = false
}
# map domain/subdomain with ALB

# # Create the DNS record for the application
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = data.aws_route53_zone.main.name
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}


# SSL  certificate _> AWS cert manager
# # Create an ACM certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = data.aws_route53_zone.main.name
  validation_method = "DNS"

  tags = {
    Name = data.aws_route53_zone.main.name
  }
}
# # Create a DNS validation record
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}


# # Validate the ACM certificate
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
