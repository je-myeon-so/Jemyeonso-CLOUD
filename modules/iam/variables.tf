variable "ec2_role_name" {
  description = "EC2 인스턴스용 IAM 역할 이름"
  type        = string
  default     = "appEC2Role"
}

variable "ec2_instance_profile_name" {
  description = "EC2 인스턴스 프로파일 이름"
  type        = string
  default     = "jemyeonso-EC2InstanceProfile"
}

variable "db_instance_profile_name" {
  description = "DB 인스턴스 프로파일 이름"
  type        = string
  default     = "jemyeonso-DBInstanceProfile"
}
