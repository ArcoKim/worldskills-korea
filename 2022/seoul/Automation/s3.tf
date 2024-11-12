resource "aws_s3_bucket" "main" {
  bucket_prefix = "kda-flink-"
  force_destroy = true
}

resource "aws_s3_object" "flink_jar" {
  bucket      = aws_s3_bucket.main.id
  key         = "kda_flink_jar/kinesis-data-analytics-flink.jar"
  source      = "./content/kinesis-data-analytics-flink.jar"
  source_hash = filemd5("./content/kinesis-data-analytics-flink.jar")
}