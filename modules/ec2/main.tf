resource "aws_instance" "win2025" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data = templatefile(var.user_data_file, {
    db_host     = var.rds_endpoint
    db_user     = var.db_username
    db_password = var.db_password
    db_name     = var.db_name
  })

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-windows2025"
  })
}
