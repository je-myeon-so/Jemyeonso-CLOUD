# openvpn 인스턴스 생성
resource "aws_instance" "openvpn" {
    ami                         = var.ami
    instance_type               = var.instance_type
    subnet_id                   = var.subnet_id
    vpc_security_group_ids      = var.vpc_security_group_ids
    associate_public_ip_address = var.associate_public_ip_address
    source_dest_check           = false
    key_name                    = ""

    user_data = file("${path.module}/openvpn-setup.sh")

    tags = merge(tomap({
        Name =  "openvpn-${var.stage}-${var.servicename}"}), var.tags)
}

# openvpn 인스턴스에 탄력적 ip 할당
resource "aws_eip_association" "openvpn_eip_asso" {
    instance_id = aws_instance.openvpn.id
    allocation_id = ""
}