resource "aws_s3_bucket" "main" {
  bucket_prefix = "kda_flink_"
  force_destroy = true
}

resource "aws_s3_object" "flink_jar" {
  bucket = aws_s3_bucket.main.id
  key    = "kda_flink_jar/kinesis-data-analytics-flink.jar"
  source = "./content/kinesis-data-analytics-flink.jar"
  etag   = filemd5("./content/kinesis-data-analytics-flink.jar")
}