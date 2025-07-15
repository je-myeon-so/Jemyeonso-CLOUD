variable "tags" {
  type = map(string)
}
variable "stage" {
  type = string
}
variable "servicename" {
  type = string
}

variable "repository_name" {
  type = string
  default = "jemyeonso-repo"
}

variable "image_tag_mutability" {
  description = "이미지 태그 변경 가능 여부"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "이미지 푸시 시 스캔 여부"
  type        = bool
  default     = true
}