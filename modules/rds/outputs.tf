output "endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.postgres.id
}
