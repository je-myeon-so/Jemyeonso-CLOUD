variable "tags" {
  type = map(string)
}
variable "stage" {
  type = string
}
variable "servicename" {
  type = string
}
variable "s3_bucket_name" {
  description = "정적 웹사이트 호스팅용 S3 버킷 이름"
  type        = string
}

variable "default_root_object" {
  description = "CloudFront 기본 루트 객체 (보통 index.html)"
  type        = string
  default     = "index.html"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name for /api traffic"
}

variable "domain_name" {
  type    = string
  default = "jemyeonso.com" 
}

variable "acm_certificate_arn" {
  type = string
  default = ""
}