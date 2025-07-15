resource "aws_ecr_repository" "ecr_repo" { # ECR 리포지토리 생성
  name = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  tags = merge(tomap({
        Name =  "ecr-${var.stage}-${var.servicename}"}), var.tags)
}
