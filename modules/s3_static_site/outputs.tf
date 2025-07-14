output "dns_name" {
    value = aws_s3_bucket.frontend.bucket_domain_name
}
output "s3_bucket_name" {
  value       = aws_s3_bucket.frontend.bucket
}
