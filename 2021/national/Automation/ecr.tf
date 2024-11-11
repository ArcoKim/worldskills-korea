resource "aws_ecr_repository" "main" {
  name                 = "wsi-api-ecr"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}