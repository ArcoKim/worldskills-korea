data "aws_iam_policy_document" "flink" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["kinesisanalytics.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flink" {
  name               = "kda_flink_role"
  assume_role_policy = data.aws_iam_policy_document.flink.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:Describe*",
      "cloudwatch:*",
      "logs:*",
      "sns:*",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "cloudwatch" {
  name   = "kda_flink_cloudwatch_policy"
  policy = data.aws_iam_policy_document.cloudwatch.json
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["logs:*"]
  }
}

resource "aws_iam_policy" "cloudwatch_logs" {
  name   = "kda_flink_cloudwatch_logs_policy"
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}

data "aws_iam_policy_document" "kinesis" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kinesis:*"]
  }
}

resource "aws_iam_policy" "kinesis" {
  name   = "kda_flink_kinesis_policy"
  policy = data.aws_iam_policy_document.kinesis.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["s3:*"]
  }
}

resource "aws_iam_policy" "s3" {
  name   = "kda_flink_s3_policy"
  policy = data.aws_iam_policy_document.s3.json
}