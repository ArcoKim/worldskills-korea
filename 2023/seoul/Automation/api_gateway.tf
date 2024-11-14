resource "aws_api_gateway_rest_api" "main" {
  name = "wsi-api"
  body = data.template_file.api.rendered

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.main.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "prod"
}

data "template_file" "api" {
  template = file("./content/api.json")

  vars = {
    api_role_arn = aws_iam_role.api.arn
    stream_name  = aws_kinesis_stream.main.name
  }
}

data "aws_iam_policy_document" "api_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "api" {
  name               = "api-gateway-kinesis-role"
  assume_role_policy = data.aws_iam_policy_document.api_assume.json
}

data "aws_iam_policy_document" "api" {
  statement {
    effect    = "Allow"
    resources = [aws_kinesis_stream.main.arn]
    actions   = ["kinesis:PutRecord"]
  }
}

resource "aws_iam_role_policy" "api" {
  name   = "kinesis_put_policy"
  role   = aws_iam_role.api.id
  policy = data.aws_iam_policy_document.api.json
}