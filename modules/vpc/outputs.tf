output "vpc_id" {
  value = aws_vpc.aws-vpc.id
}
output "public_az1_id" {
  value = aws_subnet.public-az1.id
}
output "public_az2_id" {
  value = aws_subnet.public-az2.id
}
output "service_az1_id" {
  value = aws_subnet.service-az1.id
}
output "service_az2_id" {
  value = aws_subnet.service-az2.id
}
output "db_az1_id" {
  value = aws_subnet.db-az1.id
}
output "db_az2_id" {
  value = aws_subnet.db-az2.id
}
