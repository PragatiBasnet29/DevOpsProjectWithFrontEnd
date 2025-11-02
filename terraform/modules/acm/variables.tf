output "acm_certificate_arn_frontend" {
  value = aws_acm_certificate.frontend_cert.arn
}

output "acm_certificate_arn_backend" {
  value = aws_acm_certificate.backend_cert.arn
}
