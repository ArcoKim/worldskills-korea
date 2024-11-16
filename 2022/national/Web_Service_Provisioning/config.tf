locals {
  instance_type = "c5.large"
  region        = "ap-northeast-2"
  cluster_name  = "skills-cluster"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "k8s" {
  bucket = "k8s-files-skills-2022-national"
}

resource "aws_s3_object" "config" {
  for_each = fileset("./k8s/", "**")
  bucket   = aws_s3_bucket.k8s.id
  key      = each.key
  source   = "./k8s/${each.value}"
  etag     = filemd5("./k8s/${each.value}")
}