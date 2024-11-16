resource "aws_ecr_repository" "match" {
  name         = "match-ecr"
  force_delete = true
}

resource "aws_ecr_repository" "stress" {
  name         = "stress-ecr"
  force_delete = true
}

resource "terraform_data" "match" {
  provisioner "local-exec" {
    command     = "./src/push.sh ${aws_ecr_repository.match.repository_url}"
    interpreter = ["bash", "-c"]
  }

  triggers_replace = [aws_ecr_repository.match]
}

resource "terraform_data" "stress" {
  provisioner "local-exec" {
    command     = "./src/push.sh ${aws_ecr_repository.stress.repository_url}"
    interpreter = ["bash", "-c"]
  }

  triggers_replace = [aws_ecr_repository.stress]
}
