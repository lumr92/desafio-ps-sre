resource "aws_ecr_repository" "desafio-ecr-repo" {
  name                  = "desafio-ecr-repo-lucas-menezes"
  image_tag_mutability  = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

