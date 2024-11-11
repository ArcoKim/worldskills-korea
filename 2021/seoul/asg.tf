resource "aws_autoscaling_group" "stable" {
  name                = "web-skills-ap-stable"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 10
  vpc_zone_identifier = [aws_subnet.private-a.id, aws_subnet.private-b.id]
  target_group_arns   = [aws_alb_target_group.stable.arn]

  launch_template {
    id      = aws_launch_template.stable.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "test" {
  name                = "web-skills-ap-test"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 10
  vpc_zone_identifier = [aws_subnet.private-a.id, aws_subnet.private-b.id]
  target_group_arns   = [aws_alb_target_group.test.arn]

  launch_template {
    id      = aws_launch_template.test.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "stable" {
  name                   = "web-stable-policy"
  autoscaling_group_name = aws_autoscaling_group.stable.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 10.0
  }
}

resource "aws_autoscaling_policy" "test" {
  name                   = "web-test-policy"
  autoscaling_group_name = aws_autoscaling_group.test.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 10.0
  }
}

resource "aws_launch_template" "stable" {
  name          = "web_stable_lt"
  image_id      = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.small"
  key_name      = aws_key_pair.skills.key_name
  iam_instance_profile {
    arn = aws_iam_instance_profile.s3.arn
  }

  vpc_security_group_ids = [aws_security_group.web.id]
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "web-skills-ap-stable"
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo '${var.password}' | passwd --stdin ec2-user
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    aws s3 cp s3://${aws_s3_bucket.static-s3.id}/web/v1.tar .
    tar -xvf v1.tar -C /var/www/html/
    mv /var/www/html/v1/* /var/www/html
    rm -rf /var/www/html/v1
  EOF
  )
}

resource "aws_launch_template" "test" {
  name          = "web_test_lt"
  image_id      = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.small"
  key_name      = aws_key_pair.skills.key_name
  iam_instance_profile {
    arn = aws_iam_instance_profile.s3.arn
  }

  vpc_security_group_ids = [aws_security_group.web.id]
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "web-skills-ap-test"
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo '${var.password}' | passwd --stdin ec2-user
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    aws s3 cp s3://${aws_s3_bucket.static-s3.id}/web/v2.tar .
    tar -xvf v2.tar -C /var/www/html/
    mv /var/www/html/v2/* /var/www/html
    rm -rf /var/www/html/v2
  EOF
  )
}

resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_iam_role" "s3" {
  name = "S3ReadRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.s3.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "s3" {
  name = "S3ReadRole"
  role = aws_iam_role.s3.name
}