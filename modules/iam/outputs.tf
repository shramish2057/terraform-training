output "iam_user_arn" {
  value       = aws_iam_user.manager_user.arn
  description = "IAM user for programmatic access"
}

output "iam_role_arn" {
  value       = aws_iam_role.terraform_managed_role.arn
  description = "IAM role that the user can assume"
}
