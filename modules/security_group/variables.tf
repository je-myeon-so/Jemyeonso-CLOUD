variable "stage" {
  type = string
}
variable "servicename" {
  type = string
}
variable "vpc_id" {
    type = string
}
variable "ec2_port_spring" {
    default = 8080
}
variable "ec2_port_fastapi" {
    default = 8000
}
