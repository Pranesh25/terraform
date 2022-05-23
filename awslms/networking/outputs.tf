output "vpc_id" {
  value = aws_vpc.pranesh_vpc.id

}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnetgroup.*.name
  
}

output "db_security_group" {
  value = [aws_security_group.pranesh_sg["rds"].id]
  
}