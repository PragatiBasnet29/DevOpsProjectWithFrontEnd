variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecr_repository_url" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to EC2 (e.g., 1.2.3.4/32)"
  type        = string
}