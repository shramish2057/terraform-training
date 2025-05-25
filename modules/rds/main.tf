resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-rds-subnet-group"
  })
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.environment}-postgres"
  engine                  = "postgres"
  engine_version          = "17.2"
  instance_class          = "db.m6i.xlarge"
  allocated_storage       = var.allocated_storage
  storage_type            = "gp3"
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  multi_az                = true
  publicly_accessible     = false
  deletion_protection     = true
  backup_retention_period = 7
  skip_final_snapshot     = false
  vpc_security_group_ids  = [var.sg_id]
  db_subnet_group_name    = aws_db_subnet_group.main.name

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-postgres"
  })
}
