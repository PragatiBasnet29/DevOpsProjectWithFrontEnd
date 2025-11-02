variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "project_name" {
  type = string
  default = "myapp"
}

variable "env" {
  type = string
  default = "dev"
}
