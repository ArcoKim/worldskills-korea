locals {
  filepath      = "./content"
  s3_origin_id  = "static-s3-origin"
  alb_origin_id = "alb-origin"
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
