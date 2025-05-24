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
  instance_class          = var.instance_class
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

  vpc_security_group_ids = [var.sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = merge(var.tags, {
    Name = "${var.environment}-postgres"
  })
}

# Init SQL script upload via local-exec (requires AWS CLI + DB access)
resource "null_resource" "db_init_script" {
  provisioner "local-exec" {
    command = "PGPASSWORD=${var.db_password} psql -h ${aws_db_instance.postgres.address} -U ${var.db_username} -d ${var.db_name} -f scripts/init_db.sql"
    environment = {
      PGPASSWORD = var.db_password
    }
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [aws_db_instance.postgres]
  count      = var.run_init_sql ? 1 : 0
}
