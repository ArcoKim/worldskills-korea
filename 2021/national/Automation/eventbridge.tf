resource "aws_cloudwatch_event_rule" "codepipeline-main" {
  name = "invoke-${aws_codepipeline.main.name}"
  event_pattern = jsonencode({

    "source" : [
      "aws.codecommit"
    ],
    "detail-type" : [
      "CodeCommit Repository State Change"
    ],
    "resources" : [
      "arn:aws:codecommit:ap-northeast-2:${local.account_id}:${aws_codecommit_repository.main.repository_name}"
    ],
    "detail" : {
      "event" : [
        "referenceCreated",
        "referenceUpdated"
      ],
      "referenceType" : [
        "branch"
      ],
      "referenceName" : [
        "main"
      ]
    }
  })
}

resource "aws_cloudwatch_event_rule" "codepipeline-release" {
  name = "invoke-${aws_codepipeline.release.name}"
  event_pattern = jsonencode({

    "source" : [
      "aws.codecommit"
    ],
    "detail-type" : [
      "CodeCommit Repository State Change"
    ],
    "resources" : [
      "arn:aws:codecommit:ap-northeast-2:${local.account_id}:${aws_codecommit_repository.main.repository_name}"
    ],
    "detail" : {
      "event" : [
        "referenceCreated",
        "referenceUpdated"
      ],
      "referenceType" : [
        "branch"
      ],
      "referenceName" : [
        "release"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "codepipeline-main" {
  rule      = aws_cloudwatch_event_rule.codepipeline-main.name
  target_id = "invoke-${aws_codepipeline.main.name}"
  arn       = aws_codepipeline.main.arn
  role_arn  = aws_iam_role.eventbridge.arn
}

resource "aws_cloudwatch_event_target" "codepipeline-release" {
  rule      = aws_cloudwatch_event_rule.codepipeline-release.name
  target_id = "invoke-${aws_codepipeline.release.name}"
  arn       = aws_codepipeline.release.arn
  role_arn  = aws_iam_role.eventbridge.arn
}

resource "aws_iam_role" "eventbridge" {
  name               = "invoke-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume.json
}

data "aws_iam_policy_document" "eventbridge_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [
        local.account_id
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eventbridge" {
  role       = aws_iam_role.eventbridge.name
  policy_arn = aws_iam_policy.eventbridge.arn
}

resource "aws_iam_policy" "eventbridge" {
  name   = "invoke-codepipeline-policy"
  policy = data.aws_iam_policy_document.eventbridge.json
}

data "aws_iam_policy_document" "eventbridge" {
  statement {
    effect = "Allow"
    actions = [
      "codepipeline:StartPipelineExecution"
    ]

    resources = [
      aws_codepipeline.main.arn,
      aws_codepipeline.release.arn
    ]
  }
}