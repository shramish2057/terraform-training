aws_region         = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]
environment        = "prod"
windows_ami_id     = "ami-0db3480be03d8d01c"
admin_cidr         = "77.21.254.77/32"
db_username        = "dbmaster"
run_init_sql       = true
secret_arn         = "arn:aws:secretsmanager:us-east-1:167872550708:secret:rds-prod-creds-iBHTx8"
