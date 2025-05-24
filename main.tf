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
  admin_cidr  = var.admin_cidr # Replace with your ip
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
  source             = "./modules/rds"
  subnet_ids         = module.vpc.public_subnet_ids
  sg_id              = module.sg.rds_sg_id
  db_username = var.db_username
  db_password        = var.db_password
  db_name            = "trainingdb"
  environment        = var.environment
  aws_region         = var.aws_region
  run_init_sql       = false
  tags               = local.common_tags
}

module "ec2" {
  source          = "./modules/ec2"
  ami_id          = var.windows_ami_id
  subnet_id       = module.vpc.public_subnet_ids[0]
  sg_id           = module.sg.ec2_sg_id
  key_name        = "my-keypair"
  user_data_file  = "${path.module}/scripts/user_data.ps1"
  environment     = var.environment
  tags            = local.common_tags
}

module "elb_asg" {
  source          = "./modules/elb_asg"
  subnet_ids      = module.vpc.public_subnet_ids
  vpc_id          = module.vpc.vpc_id
  ami_id          = var.windows_ami_id
  sg_id           = module.sg.elb_sg_id
  key_name        = "my-keypair"
  user_data_file  = "${path.module}/scripts/user_data.ps1"
  environment     = var.environment
  tags            = local.common_tags
}
