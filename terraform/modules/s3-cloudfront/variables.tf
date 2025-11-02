variable "bucket_name" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}
