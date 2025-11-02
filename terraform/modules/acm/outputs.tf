variable "domain_name" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "region_frontend" {
  type = string
  default = "us-east-1"
}

variable "region_backend" {
  type = string
  default = "us-west-2"
}
