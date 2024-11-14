resource "aws_kinesis_stream" "main" {
  name        = "wsi-data-stream"
  shard_count = 1

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = "wsi-delivery-stream"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.main.arn
    role_arn           = aws_iam_role.firehose.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.main.arn

    prefix             = "data/raw/"
    custom_time_zone   = "Asia/Seoul"
    buffering_size     = 1
    buffering_interval = 5
  }
}

data "aws_iam_policy_document" "firehose_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose" {
  name               = "KinesisFirehoseServiceRole-wsi-delivery-stream-ap-northeast-2"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume.json
}

data "aws_iam_policy_document" "firehose" {
  statement {
    effect    = "Allow"
    resources = [aws_s3_bucket.main.arn, "${aws_s3_bucket.main.arn}/*"]
    actions   = ["s3:AbortMultipartUpload", "s3:GetBucketLocation", "s3:GetObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:PutObject"]
  }

  statement {
    effect    = "Allow"
    resources = [aws_kinesis_stream.main.arn]
    actions   = ["kinesis:DescribeStream", "kinesis:GetShardIterator", "kinesis:GetRecords", "kinesis:ListShards"]
  }
}

resource "aws_iam_role_policy" "firehose" {
  name   = "KinesisFirehoseServicePolicy-wsi-delivery-stream-ap-northeast-2"
  role   = aws_iam_role.firehose.id
  policy = data.aws_iam_policy_document.firehose.json
}
