#DB용 Instance 생성
resource "aws_instance" "db" {
  ami                  = var.ami
  instance_type        = var.instance_type
  vpc_security_group_ids = var.sg_ids
  associate_public_ip_address = var.associate_public_ip_address
  
  subnet_id = var.subnet_id
  #source_dest_check = !var.isPortForwarding # 포트포워딩용 인스턴스면 Source/Dest 체크 비활성화
  
  root_block_device {
          delete_on_termination = true # 인스턴스 종료 시 EBS 삭제되지 않도록 설정 (기본은 true로 삭제됨)
          encrypted = true # 루트 디스크를 암호화하고 싶다면 명시해야 함 (기본은 암호화 안됨)
          volume_size = var.ebs_size # 기본 디스크 크기보다 더 큰 용량을 쓰고 싶을 때
          volume_type = var.ebs_volume
  }

  iam_instance_profile = var.iam_instance_profile_name    # DB 인스턴스에 연결할 IAM Role
  
  user_data = var.user_data
  
  key_name               = ""

  tags = merge(tomap({
        Name =  "db-${var.stage}-${var.servicename}"}), var.tags)
}
  