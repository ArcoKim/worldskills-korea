resource "aws_s3_bucket" "static-s3" {
  bucket = "skills-arco06"
}

resource "aws_s3_object" "web" {
  for_each = fileset("./content", "**")
  bucket   = aws_s3_bucket.static-s3.id
  key      = each.value
  source   = "./content/${each.value}"
  etag     = filemd5("./content/${each.value}")
}