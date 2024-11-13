resource "aws_ecs_cluster" "main" {
  name = "wsi-ecs"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "template_file" "about" {
  template = file("./content/container.json")

  vars = {
    app_name  = aws_ecr_repository.about.name
    app_image = aws_ecr_repository.about.repository_url
  }
}

resource "aws_ecs_task_definition" "about" {
  family             = "about-task-def"
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions    = data.template_file.about.rendered

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  depends_on = [terraform_data.about]
}

resource "aws_ecs_service" "about" {
  name            = "wsi-about-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.about.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.about.id]
    subnets          = [aws_subnet.private-a.id, aws_subnet.private-b.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.about.id
    container_name   = aws_ecr_repository.about.name
    container_port   = 5000
  }

  depends_on = [aws_alb_listener.main, aws_iam_role_policy_attachment.ecs_task_execution]
}

resource "aws_security_group" "about" {
  name        = "wsi-about-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5000
    to_port         = 5000
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

data "template_file" "projects" {
  template = file("./content/container.json")

  vars = {
    app_name  = aws_ecr_repository.projects.name
    app_image = aws_ecr_repository.projects.repository_url
  }
}

resource "aws_ecs_task_definition" "projects" {
  family             = "projects-task-def"
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions    = data.template_file.projects.rendered

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  depends_on = [terraform_data.projects]
}

resource "aws_ecs_service" "projects" {
  name            = "wsi-projects-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.projects.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.projects.id]
    subnets          = [aws_subnet.private-a.id, aws_subnet.private-b.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.projects.id
    container_name   = aws_ecr_repository.projects.name
    container_port   = 5000
  }

  depends_on = [aws_alb_listener.main, aws_iam_role_policy_attachment.ecs_task_execution]
}

resource "aws_security_group" "projects" {
  name        = "wsi-projects-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5000
    to_port         = 5000
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
