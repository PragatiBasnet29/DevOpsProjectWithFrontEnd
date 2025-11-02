resource "aws_ecr_repository" "repo" {
  name = var.repository_name

  image_tag_mutability = "MUTABLE"
  tags = {
    Name = var.repository_name
  }
}
