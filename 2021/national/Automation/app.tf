resource "aws_instance" "app" {
  count                  = 2
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t3.small"
  subnet_id              = element([aws_subnet.private-a.id, aws_subnet.private-b.id], count.index)
  key_name               = aws_key_pair.skills.key_name
  vpc_security_group_ids = [aws_security_group.wsi-api.id]
  iam_instance_profile   = aws_iam_instance_profile.wsi-api.name
  user_data              = file("./content/user_data.sh")

  tags = {
    Name               = "wsi-api-${count.index + 1}"
    "wsi:deploy:group" = "dev-api"
  }

  depends_on = [aws_nat_gateway.nat-a, aws_nat_gateway.nat-b]
}

resource "aws_security_group" "wsi-api" {
  name        = "wsi-api-sg"
  description = "Allow SSH, HTTP traffic"
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

resource "aws_iam_role" "wsi-api" {
  name = "wsi-api"

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

resource "aws_iam_role_policy_attachment" "ec2_codedeploy" {
  role       = aws_iam_role.wsi-api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "wsi-api" {
  name = "wsi-api"
  role = aws_iam_role.wsi-api.name
}
