output "repository_url" {
  description = "ECR 저장소 URL"
  value       = aws_ecr_repository.ecr_repo.repository_url
}

output "repository_arn" {
  description = "ECR 저장소 ARN"
  value       = aws_ecr_repository.ecr_repo.arn
}
