resource "aws_ecr_repository" "inpost" {
  name                 = var.ecr-inpost["name"]
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }
}