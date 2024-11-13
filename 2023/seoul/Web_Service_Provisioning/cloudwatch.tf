resource "aws_cloudwatch_log_group" "about" {
  name              = "/ecs/${aws_ecr_repository.about.name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "projects" {
  name              = "/ecs/${aws_ecr_repository.projects.name}"
  retention_in_days = 30
}