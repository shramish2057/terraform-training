resource "aws_launch_template" "win_lt" {
  name_prefix   = "${var.environment}-win-lt"
  image_id      = var.ami_id
  instance_type = "m7i.2xlarge"
  key_name      = var.key_name

  network_interfaces {
    security_groups             = [var.sg_id]
    associate_public_ip_address = true
  }

  user_data = filebase64(var.user_data_file)

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.environment}-ec2" })
  }
}

resource "aws_lb" "app_lb" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.environment}-alb"
  })
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.environment}-asg"
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.win_lt.id
    version = "$Latest"
  }

  target_group_arns         = [aws_lb_target_group.tg.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  # Enable AZ rebalancing for better high availability
  availability_zone_rebalance = true

  # Static tag for Name (this tag also propagates to launched EC2s)
  tag {
    key                 = "Name"
    value               = "${var.environment}-ec2"
    propagate_at_launch = true
  }

  # Dynamic tags from var.tags
  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

