resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Allow EC2 to access RDS on port 1433"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow PostgreSQL from EC2"
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.environment}-rds-sg" })
}

resource "aws_security_group" "ec2" {
  name        = "${var.environment}-ec2-sg"
  description = "Allow RDP from your IP and outbound to RDS"
  vpc_id      = var.vpc_id

  ingress {
    description = "RDP from admin IP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.environment}-ec2-sg" })
}

resource "aws_security_group" "elb" {
  name        = "${var.environment}-elb-sg"
  description = "Allow public traffic on HTTP/HTTPS"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.environment}-elb-sg" })
}
