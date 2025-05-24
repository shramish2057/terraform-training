output "rds_sg_id" {
  description = "Security Group ID for RDS"
  value       = aws_security_group.rds.id
}

output "ec2_sg_id" {
  description = "Security Group ID for EC2"
  value       = aws_security_group.ec2.id
}

output "elb_sg_id" {
  description = "Security Group ID for ELB"
  value       = aws_security_group.elb.id
}
