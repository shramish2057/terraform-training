resource "aws_iam_role" "terraform_managed_role" {
  name = "${var.environment}-infra-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::${var.account_id}:user/${var.user_name}"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "scoped_access" {
  name        = "${var.environment}-infra-policy"
  description = "Limited access to resources provisioned via Terraform"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "rds:*",
          "s3:*"
        ],
        Resource = "*",
        Condition = {
          StringLikeIfExists = {
            "aws:ResourceTag/Project" : "DevOps-Training"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.terraform_managed_role.name
  policy_arn = aws_iam_policy.scoped_access.arn
}

resource "aws_iam_user" "manager_user" {
  name = var.user_name
  tags = var.tags
}

resource "aws_iam_policy" "assume_role_user_policy" {
  name        = "${var.environment}-assume-role"
  description = "Allows IAM user to assume the managed role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = aws_iam_role.terraform_managed_role.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "sts_assume" {
  user       = aws_iam_user.manager_user.name
  policy_arn = aws_iam_policy.assume_role_user_policy.arn
}
