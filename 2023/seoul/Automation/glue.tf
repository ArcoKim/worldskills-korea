resource "aws_glue_catalog_database" "main" {
  name = "wsi-glue-database"
}

resource "aws_glue_crawler" "main" {
  database_name = aws_glue_catalog_database.main.name
  name          = "wsi-glue-crawler"
  role          = aws_iam_role.crawler.arn

  s3_target {
    path = "s3://${aws_s3_bucket.main.bucket}/data/"
  }
}

data "aws_iam_policy_document" "glue_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "crawler" {
  name               = "AWSGlueServiceRole-wsi-glue-crawler"
  assume_role_policy = data.aws_iam_policy_document.glue_assume.json
}

data "aws_iam_policy_document" "crawler" {
  statement {
    effect    = "Allow"
    resources = ["${aws_s3_bucket.main.arn}/*"]
    actions   = ["s3:GetObject", "s3:PutObject"]
  }
}

resource "aws_iam_role_policy_attachment" "crawler-glue" {
  role       = aws_iam_role.crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "crawler-s3" {
  name   = "AWSGlueServiceRole-wsi-glue-crawler-s3Policy"
  role   = aws_iam_role.crawler.id
  policy = data.aws_iam_policy_document.crawler.json
}

resource "aws_glue_job" "main" {
  name     = "wsi-glue-job"
  role_arn = aws_iam_role.glue_job.arn

  command {
    script_location = "s3://${aws_s3_bucket.glue.bucket}/script.py"
    python_version  = 3
  }
}

resource "aws_iam_role" "glue_job" {
  name               = "AWSGlueServiceRole-wsi-glue-job"
  assume_role_policy = data.aws_iam_policy_document.glue_assume.json
}

resource "aws_iam_role_policy_attachment" "job-s3" {
  role       = aws_iam_role.glue_job.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "job-glue" {
  role       = aws_iam_role.glue_job.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_workflow" "main" {
  name = "wsi-glue-workflow"
}

resource "aws_glue_trigger" "start" {
  name          = "Crawler"
  type          = "ON_DEMAND"
  workflow_name = aws_glue_workflow.main.name

  actions {
    crawler_name = aws_glue_crawler.main.name
  }
}

resource "aws_glue_trigger" "glue_job" {
  name          = "Glue Job"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.main.name

  actions {
    job_name = aws_glue_job.main.name
  }

  predicate {
    conditions {
      crawler_name = aws_glue_crawler.main.name
      crawl_state  = "SUCCEEDED"
    }
  }
}