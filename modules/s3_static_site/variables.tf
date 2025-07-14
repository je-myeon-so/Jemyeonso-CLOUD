variable "tags" {
  type = map(string)
}
variable "stage" {
  type = string
}
variable "servicename" {
  type = string
}
variable "bucket_name" {
  description = "Frontend static hosting bucket name"
  type        = string
  default = "jemyeonso-static-s3"
}
variable "cloudfront_oai_arn" {
  description = "CloudFront Origin Access Identity의 IAM ARN"
  type        = string
}