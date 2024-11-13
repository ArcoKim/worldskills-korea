resource "aws_alb" "main" {
  name            = "wsi-alb"
  internal        = false
  security_groups = [aws_security_group.alb.id]
  subnets         = [aws_subnet.public-a.id, aws_subnet.public-b.id]
}

resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_alb_target_group" "about" {
  name     = "wsi-about-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/about"
  }
}

resource "aws_alb_target_group" "projects" {
  name     = "wsi-projects-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/projects"
  }
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_alb_listener_rule" "about" {
  listener_arn = aws_alb_listener.main.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.about.arn
  }

  condition {
    path_pattern {
      values = ["/about"]
    }
  }
}

resource "aws_alb_listener_rule" "projects" {
  listener_arn = aws_alb_listener.main.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.projects.arn
  }

  condition {
    path_pattern {
      values = ["/projects"]
    }
  }
}