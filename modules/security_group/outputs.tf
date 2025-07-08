output "sg_openvpn_id" {
  value = aws_security_group.sg_openvpn.id
}
output "sg_ec2_id" {
  value = aws_security_group.sg_ec2.id
}

output "sg_alb_id" {
  value = aws_security_group.sg_alb.id
}

output "sg_db_id" {
  value = aws_security_group.sg_db.id
}