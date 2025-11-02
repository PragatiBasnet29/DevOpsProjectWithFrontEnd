output "cloudfront_domain_name" {
  value = module.s3_cloudfront.cloudfront_domain_name
}

output "s3_bucket_name" {
  value = module.s3_cloudfront.bucket_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ec2_instance_public_ip" {
  value = module.ec2_codedeploy.ec2_instance_public_ip
}