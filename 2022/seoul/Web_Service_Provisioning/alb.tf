resource "aws_alb" "main" {
  name            = "service-b-alb"
  internal        = true
  security_groups = [aws_security_group.alb.id]
  subnets         = [aws_subnet.vpc_b_private-a.id, aws_subnet.vpc_b_private-b.id]
}

resource "aws_alb_target_group" "main" {
  name                 = "service-b-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc_b.id
  deregistration_delay = 30
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }
}

resource "aws_alb_target_group_attachment" "service_b" {
  target_group_arn = aws_alb_target_group.main.arn
  target_id        = aws_instance.service_b.id
  port             = 80
}

resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}
