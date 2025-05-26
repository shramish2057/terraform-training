locals {
  common_tags = {
    Project     = "DevOps-Training"
    Environment = var.environment
    Owner       = "Shramish Kafle"
  }
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  aws_region         = var.aws_region
  availability_zones = var.availability_zones
  environment        = var.environment
  tags               = local.common_tags
}

module "sg" {
  source      = "./modules/sg"
  vpc_id      = module.vpc.vpc_id
  admin_cidr  = var.admin_cidr
  environment = var.environment
  tags        = local.common_tags
}

module "iam" {
  source      = "./modules/iam"
  environment = var.environment
  account_id  = var.account_id
  user_name   = "tf-manager"
  tags        = local.common_tags
}

module "rds" {
  source       = "./modules/rds"
  subnet_ids   = module.vpc.private_subnet_ids
  sg_id        = module.sg.rds_sg_id
  db_username  = var.db_username
  db_password  = var.db_password
  db_name      = "trainingdb"
  environment  = var.environment
  aws_region   = var.aws_region
  tags         = local.common_tags
  secret_arn   = var.secret_arn
  run_init_sql = var.run_init_sql
}

module "elb_asg" {
  source         = "./modules/elb_asg"
  subnet_ids     = module.vpc.public_subnet_ids
  vpc_id         = module.vpc.vpc_id
  ami_id         = var.windows_ami_id
  sg_id          = module.sg.elb_sg_id
  key_name       = "my-keypair"
  user_data_file = "${path.module}/scripts/user_data.ps1"
  environment    = var.environment
  tags           = local.common_tags
}

module "s3" {
  source = "./modules/s3"

  environment = var.environment
  tags       = local.common_tags
  aws_region = var.aws_region
  ec2_role_arn = module.iam.ec2_role_arn
  rds_role_arn = module.iam.rds_role_arn
}
