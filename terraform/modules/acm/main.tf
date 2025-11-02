resource "aws_acm_certificate" "frontend_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }

  provider = aws.us_east_1
}

resource "aws_route53_record" "frontend_validation" {
  zone_id = var.route53_zone_id
  name    = aws_acm_certificate.frontend_cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.frontend_cert.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.frontend_cert.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "frontend_validation" {
  certificate_arn         = aws_acm_certificate.frontend_cert.arn
  validation_record_fqdns = [aws_route53_record.frontend_validation.fqdn]
  provider                = aws.us_east_1
}

resource "aws_acm_certificate" "backend_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "backend_validation" {
  zone_id = var.route53_zone_id
  name    = aws_acm_certificate.backend_cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.backend_cert.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.backend_cert.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "backend_validation" {
  certificate_arn         = aws_acm_certificate.backend_cert.arn
  validation_record_fqdns = [aws_route53_record.backend_validation.fqdn]
}
