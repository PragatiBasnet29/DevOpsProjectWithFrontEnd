terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

// Call network module
module "network" {
  source = "./modules/network"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

// Call ACM module
module "acm" {
  source = "./modules/acm"
  domain_name = var.domain_name
  region_frontend = "us-east-1"
  region_backend = var.aws_region
}

// Call S3 + CloudFront module
module "s3_cloudfront" {
  source = "./modules/s3-cloudfront"
  bucket_name = "${var.project_name}-frontend-${var.env}"
  domain_name = var.domain_name
  acm_certificate_arn = module.acm.acm_certificate_arn_frontend
  public_subnet_ids = module.network.public_subnet_ids
}

// Call ECR repo module
module "ecr" {
  source = "./modules/ecr"
  repository_name = "${var.project_name}-backend"
}

// Call EC2 + CodeDeploy module
module "ec2_codedeploy" {
  source = "./modules/ec2-codedeploy"
  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  ecr_repository_url = module.ecr.repository_url
  acm_certificate_arn = module.acm.acm_certificate_arn_backend
  project_name = var.project_name
  env = var.env
}

