resource "aws_ecr_repository" "about" {
  name = "wsi-about"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "projects" {
  name = "wsi-projects"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "terraform_data" "about" {
  provisioner "local-exec" {
    command = "./content/push.sh ${aws_ecr_repository.about.repository_url}"
  }

  triggers_replace = [aws_ecr_repository.about]
}

resource "terraform_data" "projects" {
  provisioner "local-exec" {
    command = "./content/push.sh ${aws_ecr_repository.projects.repository_url}"
  }

  triggers_replace = [aws_ecr_repository.projects]
}