resource "aws_s3_bucket" "main" {
  bucket        = "wsi-107-arco-etl"
  force_destroy = true
}

resource "aws_s3_object" "titles" {
  bucket = aws_s3_bucket.main.id
  key    = "data/ref/titles.json"
  source = "./content/titles.json"
  etag   = filemd5("./content/titles.json")
}

resource "aws_s3_object" "samplelog" {
  bucket = aws_s3_bucket.main.id
  key    = "data/raw/2022/01/01/samplelog.json"
  source = "./content/samplelog.json"
  etag   = filemd5("./content/samplelog.json")
}

resource "aws_s3_bucket" "glue" {
  bucket_prefix = "etl-script-"
  force_destroy = true
}

resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.glue.id
  key    = "script.py"
  source = "./content/script.py"
  etag   = filemd5("./content/script.py")
}