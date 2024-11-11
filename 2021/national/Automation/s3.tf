resource "aws_s3_bucket" "configs" {
  bucket_prefix = "wsi-configs-"
  force_destroy = true
}

data "template_file" "launch" {
  template = file("./content/ec2_launch.sh")

  vars = {
    image_id          = data.aws_ami.amazon-linux-2.id
    key_name          = aws_key_pair.skills.key_name
    security_group_id = aws_security_group.wsi-api.id
    subnet_id         = aws_subnet.private-a.id
    iam_role_name     = aws_iam_instance_profile.wsi-api.name
  }
}

resource "aws_s3_object" "launch" {
  bucket  = aws_s3_bucket.configs.id
  key     = "ec2_launch.sh"
  content = data.template_file.launch.rendered
  etag    = md5(data.template_file.launch.rendered)
}

resource "aws_s3_object" "user_data" {
  bucket = aws_s3_bucket.configs.id
  key    = "user_data.sh"
  source = "./content/user_data.sh"
  etag   = filemd5("./content/user_data.sh")
}