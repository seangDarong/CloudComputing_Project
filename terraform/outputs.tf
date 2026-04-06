output "alb_dns_name" {
  description = "Public URL of the app"
  value       = aws_lb.main.dns_name
}

output "vpc_id" {
  description = "Used by RDS and IAM teammates"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Used by RDS teammate for subnet group"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "public_subnet_ids" {
  description = "Used if teammates need public subnet refs"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "ec2_security_group_id" {
  description = "Used by RDS teammate to allow DB access from EC2"
  value       = aws_security_group.ec2.id
}
