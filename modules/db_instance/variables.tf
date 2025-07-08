variable "tags" {
  type = map(string)
}
variable "stage" {
  type = string
}
variable "servicename" {
  type = string
}

variable "vpc_id" {
  type  = string
}
variable "subnet_id" {
  type  = string
}
variable "ami" {
  type  = string
}
variable "instance_type" {
  type  = string
}
variable "ebs_volume" {
  type = string
}
variable "ebs_size" {
  type = number
}
variable "associate_public_ip_address" {
  type = bool
  default = false
}
variable "isPortForwarding" {
  type = bool
  default = false
}
variable "sg_ids" {
  type = list(string)
}

variable "iam_instance_profile_name" {
  description = "DB 인스턴스에 연결할 IAM 인스턴스 프로파일 이름"
  type        = string
}

variable "user_data" {
  description = "DB EC2 인스턴스 부팅 시 실행할 user_data 스크립트"
  type        = string
  default     = <<-EOF
              #!/bin/bash
              set -e

              export DEBIAN_FRONTEND=noninteractive
              
              echo "=== Installing MySQL ==="
              apt-get update -y
              apt-get install -y mysql-server

              echo "=== Starting MySQL ==="
              systemctl enable mysql
              systemctl start mysql

              #-------------------------------
              # AWS CLI 설치
              #-------------------------------
              apt-get install -y unzip
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install

              echo "=== Setting up MySQL root user and database ==="
              mysql --user=root <<EOSQL
              ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '12345678';
              CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '12345678';
              GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
              CREATE DATABASE IF NOT EXISTS jemyeonso;
              FLUSH PRIVILEGES;
              EOSQL

              echo "=== Allowing remote MySQL access ==="
              sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
              systemctl restart mysql
              EOF
}
