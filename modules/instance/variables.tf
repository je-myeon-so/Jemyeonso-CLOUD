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
variable "user_data" {
  description = "EC2 인스턴스 부팅 시 실행할 user_data 스크립트 (base64 인코딩 필요 없음)"
  type        = string
  default     = <<-EOF
                #!/bin/bash
                set -e

                #-------------------------------
                # 시스템 패키지 업데이트
                #-------------------------------
                apt-get update -y
                apt-get upgrade -y

                #-------------------------------
                # CodeDeploy 에이전트 설치
                #-------------------------------
                apt-get install -y ruby wget
                cd /home/ubuntu
                wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
                chmod +x ./install
                ./install auto
                systemctl start codedeploy-agent
                systemctl enable codedeploy-agent

                #-------------------------------
                # Docker 설치 및 설정
                #-------------------------------
                apt-get install -y \
                  ca-certificates \
                  curl \
                  gnupg \
                  lsb-release

                mkdir -p /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

                echo \
                  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
                  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
                  | tee /etc/apt/sources.list.d/docker.list > /dev/null

                apt-get update -y
                apt-get install -y docker-ce docker-ce-cli containerd.io

                systemctl start docker
                systemctl enable docker
                usermod -aG docker ubuntu

                #-------------------------------
                # Docker Compose 설치
                #-------------------------------
                curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
                  -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose

                #-------------------------------
                # AWS CLI 설치
                #-------------------------------
                apt-get install -y unzip
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                ./aws/install

                #-------------------------------
                # 디렉토리 생성 및 파일 작성
                #-------------------------------
                mkdir -p /home/ubuntu/deploy/scripts
                mkdir -p /home/ubuntu/logs
                mkdir -p /home/ubuntu/fastapi_logs

                chown ubuntu:ubuntu /home/ubuntu/deploy
                chown ubuntu:ubuntu /home/ubuntu/deploy/scripts
                chown ubuntu:ubuntu /home/ubuntu/logs
                chown ubuntu:ubuntu /home/ubuntu/fastapi_logs

                # deploy.sh 생성
                cat << 'EODEPLOY' > /home/ubuntu/deploy/scripts/deploy.sh
                #!/bin/bash
                set -e

                cd /home/ubuntu/deploy

                # 기존 컨테이너 종료 및 제거
                echo "[INFO] Stopping existing containers..."
                docker compose down

                if [ -f /home/ubuntu/deploy/ai.env ]; then
                  rm /home/ubuntu/deploy/ai.env
                fi

                # FastAPI용 환경변수 로드
                echo "[INFO] Fetching FastAPI environment variables from SSM..."
                aws ssm get-parameters-by-path \
                  --path "/fastapi/" \
                  --with-decryption \
                  --query "Parameters[*].{Name:Name,Value:Value}" \
                  --output text | while read name value; do
                    key=$(basename "$name")
                    echo "$key=$value" >> /home/ubuntu/deploy/ai.env
                done

                # Docker Compose로 실행
                docker compose up -d

                EODEPLOY

                chown ubuntu:ubuntu /home/ubuntu/deploy/scripts/deploy.sh

                # docker-compose.yaml 생성
                cat << 'EOCOMPOSE' > /home/ubuntu/deploy/docker-compose.yaml
                version: '3.8'

                services:
                  spring:
                    image: <계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com/<ECR-REPO-이름>:spring-latest
                    ports:
                      - "8080:8080"
                    volumes:
                      - /home/ubuntu/logs:/app/logs
                    networks:
                      - backend

                  fastapi:
                    image: <계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com/<ECR-REPO-이름>:fastapi-latest 
                    ports:
                      - "8000:8000"
                    env_file:
                      - /home/ubuntu/deploy/ai.env
                    volumes:
                      - /home/ubuntu/fastapi_logs:/fastapi/logs
                    networks:
                      - backend

                networks:
                  backend:
                    driver: bridge
                EOCOMPOSE

                chown ubuntu:ubuntu /home/ubuntu/deploy/docker-compose.yaml
              EOF
}

variable "iam_instance_profile_name" {
  description = "EC2 인스턴스에 연결할 IAM 인스턴스 프로파일 이름"
  type        = string
}