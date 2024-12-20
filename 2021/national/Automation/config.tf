provider "aws" {
  region = "ap-northeast-2"
}

data "aws_caller_identity" "current" {}

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

locals {
  account_id = data.aws_caller_identity.current.account_id
}