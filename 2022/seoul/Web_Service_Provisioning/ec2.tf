resource "aws_instance" "bastion_a" {
  ami                         = data.aws_ami.amazon-linux-2023.id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.vpc_a_public-a.id
  key_name                    = aws_key_pair.vpc_a.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_a.id]

  tags = {
    Name = "Bastion_A"
  }
}

resource "aws_security_group" "bastion_a" {
  name        = "bastion_a-sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

resource "aws_instance" "service_a" {
  ami                         = data.aws_ami.amazon-linux-2023.id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.vpc_a_private-a.id
  key_name                    = aws_key_pair.vpc_a.key_name
  vpc_security_group_ids      = [aws_security_group.service_a.id]

  tags = {
    Name = "Service_A"
  }
}

resource "aws_security_group" "service_a" {
  name        = "service_a-sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_a.id]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "vpc_a" {
  key_name   = "vpc_a"
  public_key = file("~/vpc_a/id_rsa.pub")
}

resource "aws_instance" "bastion_b" {
  ami                         = data.aws_ami.amazon-linux-2023.id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.vpc_b_public-a.id
  key_name                    = aws_key_pair.skills.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_b.id]

  tags = {
    Name = "Bastion_B"
  }
}

resource "aws_security_group" "bastion_b" {
  name        = "bastion_b-sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

resource "aws_instance" "service_b" {
  ami                         = data.aws_ami.amazon-linux-2023.id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.vpc_b_private-b.id
  key_name                    = aws_key_pair.vpc_b.key_name
  vpc_security_group_ids      = [aws_security_group.service_b.id]
  user_data                   = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "WorldSkills 2022 Seoul" > /var/www/html/index.html
  EOF

  tags = {
    Name = "Service_B"
  }

  depends_on = [aws_nat_gateway.vpc_b_nat-a]
}

resource "aws_security_group" "service_b" {
  name        = "service_b-sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_b.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "vpc_b" {
  key_name   = "vpc_b"
  public_key = file("~/vpc_b/id_rsa.pub")
}